module Tickets
  class Booking
    extend Callable

    def initialize(event, user, ticket_count)
      @event = event
      @user = user
      @ticket_count = ticket_count.to_i
    end

    def call
      ActiveRecord::Base.transaction do
        tickets = create_tickets!
        update_event_availability!(tickets.size)
        tickets.each { |ticket| confirm_ticket!(ticket) }

        ServiceResult.new(success: true, data: tickets)
      end
    rescue TicketCreationError, TicketBookingError => e
      ServiceResult.new(success: false, errors: [e.message])
    rescue StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :event, :user, :ticket_count

    def create_tickets!
      Array.new(ticket_count) { Tickets::Create.call(event, user).data }
    end

    def confirm_ticket!(ticket)
      unless ticket.confirm!
        raise TicketBookingError, "Ticket confirmation failed: #{ticket.errors.full_messages.join(', ')}"
      end
      ticket
    end

    def update_event_availability!(num_tickets)
      Tickets::EventAvailabilityUpdater.call(event, -num_tickets)
    end
  end
end
