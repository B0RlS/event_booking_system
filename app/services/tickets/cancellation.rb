module Tickets
  class Cancellation
    extend Callable
    include SharedValidations

    def initialize(event, tickets, user)
      @event = event
      @tickets = tickets
      @user = user
    end

    def validate!
      validate_event_tickets!
      validate_event!
      validate_user!
      validate_user_tickets!
      validate_not_cancelled!
    end

    def call
      validate!

      ActiveRecord::Base.transaction do
        tickets.each do |ticket|
          event.increment_available_tickets!
          cancel_ticket!(ticket)
        end
        ServiceResult.new(success: true, data: tickets)
      end
    rescue StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :event, :tickets, :user

    def cancel_ticket!(ticket)
      return if ticket.cancel!

      raise Tickets::Errors::TicketCancellationError,
            "Ticket cancellation failed: #{ticket.errors.full_messages.join(', ')}"
    end
  end
end
