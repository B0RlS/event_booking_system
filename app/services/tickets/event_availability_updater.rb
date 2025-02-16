module Tickets
  class EventAvailabilityUpdater
    extend Callable

    def initialize(event, delta)
      @event = event
      @delta = delta.to_i
      @available_tickets_count = event.available_tickets + delta
    end

    def call
      raise EventAvailabilityError, 'Not enough available tickets' if available_tickets_count.negative?
      unless event.update!(available_tickets: available_tickets_count)
        raise EventAvailabilityError, 'Failed to update event availability'
      end

      ServiceResult.new(success: true, data: event)
    end

    private

    attr_reader :event, :delta, :available_tickets_count
  end
end
