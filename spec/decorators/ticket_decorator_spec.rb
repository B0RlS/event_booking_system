require 'rails_helper'

RSpec.describe TicketDecorator, type: :decorator do
  subject { described_class.new(ticket) }

  let(:ticket) { create(:ticket, :booked, price_cents: 500, currency: 'EUR', state: 'booked') }

  describe '#as_json' do
    it 'returns decorated ticket' do
      expect(subject.as_json).to eq({
        id: ticket.id,
        user_id: ticket.user_id,
        event_id: ticket.event_id,
        price: Money.new(ticket.price_cents, ticket.currency).format,
        status: ticket.state,
        booked_at: ticket.booked_at&.strftime('%Y-%m-%d %H:%M'),
        cancelled_at: ticket.cancelled_at&.strftime('%Y-%m-%d %H:%M')
      })
    end
  end
end
