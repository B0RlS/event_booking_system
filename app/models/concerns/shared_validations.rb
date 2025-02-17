module SharedValidations
  extend ActiveSupport::Concern

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

  def validate_cancelation_for_event!
    raise Events::Errors::EventOperationError, 'Event must be in active to cancel' unless event.can_cancel?
  end

  def validate_required_event_params!(params)
    missing = Event::REQUIRED_KEYS.select { |k| params[k].blank? }

    raise Events::Errors::EventOperationError, "Missing event parameters: #{missing.join(', ')}" if missing.any?
  end
end
