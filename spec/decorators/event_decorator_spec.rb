require 'rails_helper'

RSpec.describe EventDecorator, type: :decorator do
  subject { described_class.new(event) }

  let(:event) { create(:event, ticket_price_cents: 1000, currency: 'USD') }

  describe '#as_json' do
    it 'returns decorated event' do
      expect(subject.as_json).to eq({
                                      id: event.id,
                                      name: event.name,
                                      description: event.description,
                                      location: event.location,
                                      start_time: I18n.l(event.start_time, format: :long),
                                      end_time: I18n.l(event.end_time, format: :long),
                                      state: event.state,
                                      tickets_available: event.available_tickets,
                                      tickets_total: event.total_tickets,
                                      price: Money.new(event.ticket_price_cents, event.currency).format,
                                      created_by: event.creator.id
                                    })
    end
  end
end
