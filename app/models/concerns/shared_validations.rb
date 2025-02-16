module SharedValidations
  extend ActiveSupport::Concern

  included do
    def validate_event!
      raise Tickets::Errors::TicketOperationError, 'Event is invalid' unless event.valid?
    end

    def validate_user!
      raise Tickets::Errors::TicketOperationError, 'User is invalid' unless user.valid?
    end

    def validate_ticket_count!(ticket_count)
      return if ticket_count.is_a?(Integer) && ticket_count.positive?

      raise Tickets::Errors::TicketOperationError, 'Ticket count must be a positive integer'
    end

    def validate_event_tickets!
      return unless tickets.reject { |ticket| ticket.event_id == event.id }.any?

      raise Tickets::Errors::TicketOperationError,
            'Some tickets do not belong to the specified event'
    end

    def validate_user_tickets!
      return unless tickets.reject { |ticket| ticket.user_id == user.id }.any?

      raise Tickets::Errors::TicketOperationError,
            'Some tickets do not belong to the user'
    end

    def validate_available_tickets!(ticket_count)
      return unless event.available_tickets < ticket_count

      raise Tickets::Errors::TicketOperationError,
            'Not enough available tickets'
    end

    def validate_not_cancelled!
      already_cancelled = tickets.select(&:cancelled?)
      raise Tickets::Errors::TicketOperationError, 'Some tickets are already cancelled' if already_cancelled.any?
    end

    def validate_event_params!(params)
      required_keys = %i[name description location start_time total_tickets ticket_price_cents currency]

      missing = required_keys.select { |k| params[k].blank? }
      if missing.any?
        raise Tickets::Errors::EventOperationError, "Missing event parameters: #{missing.join(', ')}"
      end
    end
  end
end

