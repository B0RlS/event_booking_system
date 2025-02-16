module Tickets
  class Create
    extend Callable

    def initialize(event, user)
      @event = event
      @user = user
      @price_cents = event.ticket_price_cents
      @currency = event.currency
    end

    def call
      ticket = Ticket.new(
        event: event,
        user: user,
        price_cents: price_cents,
        currency: currency,
        state: 'pending'
      )
      raise TicketCreationError, ticket.errors.full_messages.join(', ') unless ticket.save

      ServiceResult.new(success: true, data: ticket)
    end

    private

    attr_reader :event, :user, :price_cents, :currency
  end
end
