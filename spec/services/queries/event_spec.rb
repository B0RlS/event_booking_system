require 'rails_helper'

RSpec.describe Queries::Event, type: :query do
  subject { described_class }

  let!(:active_event1) { create(:event, start_time: 1.day.from_now, ticket_price_cents: 5000) }
  let!(:active_event2) { create(:event, start_time: 2.days.from_now, ticket_price_cents: 6000) }
  let!(:finished_event1) { create(:event, :finished, ticket_price_cents: 90_000) }
  let!(:cancelled_event1) do
    create(:event, :cancelled, ticket_price_cents: 12_000, start_time: 12.day.from_now, end_time: 15.days.from_now)
  end
  let!(:cancelled_event2) do
    create(:event, :cancelled, ticket_price_cents: 10_000, start_time: 11.day.from_now, end_time: 12.days.from_now)
  end
  let!(:cheap_event) { create(:event, start_time: 4.day.from_now, ticket_price_cents: 2000) }
  let!(:expensive_event) { create(:event, start_time: 4.5.day.from_now, ticket_price_cents: 12_000) }

  describe '.by_name' do
    it 'returns events matching the name', :aggregate_failures do
      expect(subject.by_name(active_event1.name)).to contain_exactly(active_event1)
      expect(subject.by_name('nonexistent')).to be_empty
    end
  end

  describe '.by_state' do
    it 'returns events with a specific state', :aggregate_failures do
      expect(subject.by_state('active')).to match_array([active_event1, active_event2, cheap_event, expensive_event])
      expect(subject.by_state('finished')).to match_array([finished_event1])
      expect(subject.by_state('cancelled')).to match_array([cancelled_event1, cancelled_event2])
    end
  end

  describe '.by_location' do
    it 'returns events matching the location', :aggregate_failures do
      expect(subject.by_location(active_event1.location)).to contain_exactly(active_event1)
    end
  end

  describe '.by_start_time' do
    it 'returns events within a start time range', :aggregate_failures do
      expect(subject.by_start_time(1.5.day.from_now..3.days.from_now)).to contain_exactly(active_event2)
    end
  end

  describe '.by_end_time' do
    it 'returns events within an end time range', :aggregate_failures do
      expect(subject.by_end_time(10.day.ago..Time.current)).to include(finished_event1)
    end
  end

  describe '.upcoming' do
    it 'returns upcoming events', :aggregate_failures do
      expect(subject.upcoming).to include(active_event1, active_event2, cheap_event, expensive_event)
    end
  end

  describe '.past' do
    it 'returns past events', :aggregate_failures do
      expect(subject.past).to include(finished_event1)
    end
  end

  describe '.with_available_tickets' do
    it 'returns events with available tickets', :aggregate_failures do
      expect(subject.with_available_tickets).to include(active_event1, active_event2)
    end
  end

  describe '.by_price_range' do
    it 'returns events within a price range', :aggregate_failures do
      expect(subject.by_price_range(3000, 7000)).to include(active_event1, active_event2)
      expect(subject.by_price_range(3000, 7000)).not_to include(cheap_event, expensive_event)
    end
  end

  describe '.by_id' do
    it 'returns an event by ID', :aggregate_failures do
      expect(subject.by_id(active_event1.id)).to eq(active_event1)
    end
  end

  describe '.by_id' do
    let!(:ticket) { create(:ticket, :booked, event: active_event1) }

    it 'returns an event by ID', :aggregate_failures do
      expect(subject.by_ticket(ticket)).to contain_exactly(active_event1)
    end
  end

  describe '.by_ids' do
    it 'returns events by IDs', :aggregate_failures do
      expect(subject.by_ids([active_event1.id, active_event2.id])).to match_array([active_event1, active_event2])
    end
  end

  describe '.order_by_start_time' do
    it 'orders events by start_time asc', :aggregate_failures do
      expect(subject.order_by_start_time(:asc).first).to eq(finished_event1)
    end

    it 'orders events by start_time desc', :aggregate_failures do
      expect(subject.order_by_start_time(:desc).first).to eq(expensive_event)
    end
  end
end
