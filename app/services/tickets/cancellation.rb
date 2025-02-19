module Tickets
  class Cancellation < ApplicationService
    def initialize(ticket_ids, user)
      super()
      @ticket_ids = ticket_ids
      @user = user
    end

    def call
      validate!
      ActiveRecord::Base.transaction do
        tickets.each do |ticket|
          ticket.event.increment_available_tickets!
          cancel_ticket!(ticket)
        end
        ServiceResult.new(success: true, data: tickets)
      end
    rescue StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :ticket_ids, :user

    def validate!
      validate_policy!(TicketPolicy.new(user, tickets).cancel?, 'Not authorized to cancel tickets')
      validate_user_tickets!
      validate_not_cancelled!
    end

    def cancel_ticket!(ticket)
      return if ticket.cancel!

      raise Tickets::Errors::TicketCancellationError,
            "Ticket cancellation failed: #{ticket.errors.full_messages.join(', ')}"
    end

    def tickets
      @tickets ||= Queries::Ticket.cached_find(ticket_ids)
    end

    def validate_user_tickets!
      return unless tickets.reject { |ticket| ticket.user_id == user.id }.any?

      raise Tickets::Errors::TicketOperationError,
            'Some tickets do not belong to the user'
    end

    def validate_not_cancelled!
      already_cancelled = tickets.select(&:cancelled?)
      raise Tickets::Errors::TicketOperationError, 'Some tickets are already cancelled' if already_cancelled.any?
    end
  end
end
