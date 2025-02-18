class TicketDecorator < Draper::Decorator
  delegate_all

  def as_json(*)
    {
      id: id,
      user_id: user_id,
      event_id: event_id,
      price: Money.new(price_cents, currency).format,
      status: state,
      booked_at: booked_at&.strftime('%Y-%m-%d %H:%M'),
      cancelled_at: cancelled_at&.strftime('%Y-%m-%d %H:%M')
    }
  end
end
