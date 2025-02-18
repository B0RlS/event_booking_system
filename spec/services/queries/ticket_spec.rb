require 'rails_helper'

RSpec.describe Queries::Ticket, type: :query do
  subject { described_class }

  let(:event) { create(:event) }
  let(:event2) { create(:event) }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }

  let!(:booked_ticket1) { create(:ticket, :booked, event: event2, user: user, price_cents: 5_000) }
  let!(:booked_ticket2) { create(:ticket, :booked, event: event, user: user2, price_cents: 10_000) }
  let!(:pending_ticket1) { create(:ticket, event: event, user: user, price_cents: 50_000) }
  let!(:pending_ticket2) { create(:ticket, event: event2, user: user2, price_cents: 52_000) }
  let!(:cancelled_ticket1) { create(:ticket, :cancelled, event: event2, user: user, price_cents: 6_900) }
  let!(:cancelled_ticket2) { create(:ticket, :cancelled, event: event, user: user2, price_cents: 500) }

  describe '.by_state' do
    it 'returns tickets with a specific state', :aggregate_failures do
      expect(subject.by_state('booked')).to match_array([booked_ticket1, booked_ticket2])
      expect(subject.by_state('pending')).to match_array([pending_ticket1, pending_ticket2])
      expect(subject.by_state('cancelled')).to match_array([cancelled_ticket1, cancelled_ticket2])
    end
  end

  describe '.by_event' do
    it 'returns tickets for a specific event' do
      expect(subject.by_event(event)).to contain_exactly(booked_ticket2, pending_ticket1, cancelled_ticket2)
    end
  end

  describe '.by_event_id' do
    it 'returns tickets for a specific event_id' do
      expect(subject.by_event_id(event.id)).to contain_exactly(booked_ticket2, pending_ticket1, cancelled_ticket2)
    end
  end

  describe '.by_user' do
    it 'returns tickets for a specific user' do
      expect(subject.by_user(user)).to contain_exactly(booked_ticket1, pending_ticket1, cancelled_ticket1)
    end
  end

  describe '.by_price_range' do
    let!(:cheap_ticket) { create(:ticket, price_cents: 2000) }
    let!(:expensive_ticket) { create(:ticket, price_cents: 15_000) }

    it 'returns tickets within a price range' do
      expect(subject.by_price_range(3000, 7000)).to contain_exactly(booked_ticket1, cancelled_ticket1)
    end
  end

  describe '.booked' do
    it 'returns only booked tickets' do
      expect(subject.booked).to match_array([booked_ticket1, booked_ticket2])
    end
  end

  describe '.booked_and_cancelled' do
    it 'returns only booked and cancelled tickets' do
      expect(subject.booked_and_cancelled).to match_array([booked_ticket1, booked_ticket2, cancelled_ticket1,
                                                           cancelled_ticket2])
    end
  end

  describe '.booked_and_pending' do
    it 'returns only booked and pending tickets' do
      expect(subject.booked_and_pending).to match_array([booked_ticket1, booked_ticket2, pending_ticket1,
                                                         pending_ticket2])
    end
  end

  describe '.pending' do
    it 'returns only pending tickets' do
      expect(subject.pending).to match_array([pending_ticket1, pending_ticket2])
    end
  end

  describe '.cancelled' do
    it 'returns only cancelled tickets' do
      expect(subject.cancelled).to match_array([cancelled_ticket1, cancelled_ticket2])
    end
  end

  describe '.recent' do
    it 'returns tickets ordered by created_at desc' do
      expect(subject.recent.first).to eq(cancelled_ticket2)
    end
  end

  describe '.oldest' do
    it 'returns tickets ordered by created_at asc' do
      expect(subject.oldest.first).to eq(booked_ticket1)
    end
  end
end
