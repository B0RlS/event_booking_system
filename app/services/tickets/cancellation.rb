module Tickets
  class Cancellation
    extend Callable

    def initialize(ticket, user)
      @ticket = ticket
      @user = user
    end

    def call
      ActiveRecord::Base.transaction do
        cancel_ticket!
        update_event_availability!
        ServiceResult.new(success: true, data: ticket)
      end
    rescue TicketCancellationError => e
        ServiceResult.new(success: false, errors: [e.message])
    rescue StandardError => e
        ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :ticket, :user

    def cancel_ticket!
      return if ticket.cancel!
      raise TicketCancellationError, "Ticket cancellation failed: #{ticket.errors.full_messages.join(', ')}"
    end

    def update_event_availability!
      Tickets::EventAvailabilityUpdater.call(ticket.event, 1)
    end
  end
end
