class EventDecorator < Draper::Decorator
  delegate_all

  def as_json(*) # rubocop:disable  Metrics/AbcSize
    {
      id: id,
      name: name,
      description: description,
      location: location,
      start_time: h.l(start_time, format: :long),
      end_time: h.l(end_time, format: :long),
      state: state,
      tickets_available: available_tickets,
      tickets_total: total_tickets,
      price: Money.new(ticket_price_cents, currency).format,
      created_by: creator.id
    }
  end
end
