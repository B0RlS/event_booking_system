module Tickets
  class Creation < ApplicationService
    def initialize(event, user)
      super()
      @event = event
      @user = user
    end

    def call
      ticket = Ticket.new(
        event: event,
        user: user,
        price_cents: event.ticket_price_cents,
        currency: event.currency,
        state: 'pending'
      )
      raise Tickets::Errors::TicketOperationError, ticket.errors.full_messages.join(', ') unless ticket.save

      ServiceResult.new(success: true, data: ticket)
    end

    private

    attr_reader :event, :user
  end
end
