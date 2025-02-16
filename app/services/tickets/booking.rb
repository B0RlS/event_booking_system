module Tickets
  class Booking
    extend Callable
    include SharedValidations

    def initialize(event, user, ticket_count)
      @event = event
      @user = user
      @ticket_count = ticket_count
    end

    def validate!
      validate_event!
      validate_user!
      validate_available_tickets!(ticket_count)
      validate_ticket_count!(ticket_count)
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
    rescue Tickets::Errors::TicketOperationError, Tickets::Errors::TicketBookingError => e
      ServiceResult.new(success: false, errors: [e.message])
    rescue StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :event, :user, :ticket_count

    def create_tickets
      Array.new(ticket_count) { Tickets::Create.call(event, user).data }
    end

    def confirm_ticket(ticket)
      return if ticket.confirm!

      raise Tickets::Errors::TicketBookingError,
            "Ticket confirmation failed: #{ticket.errors.full_messages.join(', ')}"
    end
  end
end
