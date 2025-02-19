module Tickets
  class Booking < ApplicationService
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
    rescue Tickets::Errors::TicketBookingError, StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :event_id, :user, :ticket_count

    def validate!
      validate_policy!(TicketPolicy.new(user, nil).book?, 'Not authorized to book tickets')
      validate_ticket_event!
      validate_available_tickets!(ticket_count)
      validate_ticket_count!(ticket_count)
    end

    def create_tickets
      Array.new(ticket_count) { Tickets::Creation.call(event, user).data }
    end

    def confirm_ticket(ticket)
      return if ticket.confirm!

      raise Tickets::Errors::TicketBookingError, "Ticket confirmation failed: #{ticket.errors.full_messages.join(', ')}"
    end

    def event
      @event ||= Queries::Event.cached_find(event_id)
    end

    def validate_ticket_count!(ticket_count)
      return if ticket_count.is_a?(Integer) && ticket_count.positive?

      raise Tickets::Errors::TicketOperationError, 'Ticket count must be a positive integer'
    end

    def validate_available_tickets!(ticket_count)
      return unless event.available_tickets < ticket_count

      raise Tickets::Errors::TicketOperationError,
            'Not enough available tickets'
    end

    def validate_ticket_event!
      raise Tickets::Errors::TicketOperationError, 'Event is invalid' unless event.valid?
      raise Tickets::Errors::TicketOperationError, 'Event is cancelled' if event.cancelled?
    end
  end
end
