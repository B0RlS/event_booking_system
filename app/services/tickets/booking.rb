module Tickets
  class Booking
    extend Callable

    def initialize(event, user, quantity)
      @event = event
      @user = user
      @quantity = quantity.to_i
    end

    def call
      ActiveRecord::Base.transaction do
        ticket = create_ticket!
        confirm_ticket!(ticket)
        update_event_availability!(ticket)

        return ServiceResult.new(success: true, data: ticket)
      end
    rescue TicketCreationError, TicketBookingError => e
      ServiceResult.new(success: false, errors: [e.message])
    rescue StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :event, :user, :quantity

    def create_ticket!
      creation_result = Tickets::Create.call(event, user, quantity)
      creation_result.data
    end

    def confirm_ticket!(ticket)
      unless ticket.confirm!
        raise TicketBookingError, "Ticket confirmation failed: #{ticket.errors.full_messages.join(', ')}"
      end

      ticket
    end

    def update_event_availability!(ticket)
      new_available = event.available_tickets - ticket.quantity
      raise TicketBookingError, 'Not enough available tickets' if new_available.negative?

      return if event.update(available_tickets: new_available)

      raise TicketBookingError, 'Failed to update event availability'
    end
  end
end
