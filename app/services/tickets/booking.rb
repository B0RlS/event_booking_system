module Tickets
  class Booking < ApplicationService
    include SharedValidations
    include SharedPolicyValidation

    def initialize(event_id, user, ticket_count)
      super()
      @event_id = event_id
      @user = user
      @ticket_count = ticket_count
    end

    def call
      validate!
      ActiveRecord::Base.transaction do
        tickets = create_tickets
        tickets.each do |ticket|
          event.decrement_available_tickets!
          confirm_ticket(ticket)
        end
        ServiceResult.new(success: true, data: tickets)
      end
    rescue StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :event_id, :user, :ticket_count

    def validate!
      validate_policy!(TicketPolicy.new(user, nil).book?, 'Not authorized to book tickets')
      validate_event!
      validate_user!
      validate_available_tickets!(ticket_count)
      validate_ticket_count!(ticket_count)
    end

    def create_tickets
      Array.new(ticket_count) { Tickets::Create.call(event, user).data }
    end

    def confirm_ticket(ticket)
      return if ticket.confirm!

      raise Tickets::Errors::TicketBookingError,
            "Ticket confirmation failed: #{ticket.errors.full_messages.join(', ')}"
    end

    def event
      @event ||= Queries::Event.cached_find(event_id)
    end
  end
end
