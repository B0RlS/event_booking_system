require 'rails_helper'

RSpec.describe Tickets::Cancellation, type: :service do
  subject { described_class.call(ticket_ids, user) }

  let(:event) { create(:event, total_tickets: 100, available_tickets: 80, ticket_price_cents: 5000, currency: 'USD') }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:other_event) { create(:event) }
  let(:ticket_ids) { [ticket1.id, ticket2.id, ticket3.id] }
  let(:ticket1) { create(:ticket, :booked, event: event, user: user) }
  let(:ticket2) { create(:ticket, :booked, event: event, user: user) }
  let(:ticket3) { create(:ticket, :booked, event: event, user: user) }

  describe '.call' do
    context 'when cancellation is successful' do
      it 'returns a successful result and updates event availability', :aggregate_failures do
        expect(subject.success?).to be true
        expect(subject.data.all?(&:cancelled?)).to be true
        expect(event.reload.available_tickets).to eq(83)
      end
    end

    context 'when tickets do not belong to the user' do
      let(:ticket1) { create(:ticket, :booked, event: event, user: other_user) }

      before { allow_any_instance_of(TicketPolicy).to receive(:cancel?).and_return(true) }

      it 'raises an error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Some tickets do not belong to the user')
      end
    end

    context 'when some tickets are already cancelled' do
      let(:ticket1) { create(:ticket, :cancelled, event: event, user: user) }

      before { allow_any_instance_of(TicketPolicy).to receive(:cancel?).and_return(true) }

      it 'raises an error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Some tickets are already cancelled')
      end
    end

    context 'when ticket cancellation fails' do
      before do
        allow_any_instance_of(Ticket).to receive(:cancel!).and_return(false)
      end

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to match(/Ticket cancellation failed/)
      end
    end

    context 'when user can not cancel tickets' do
      before { allow_any_instance_of(TicketPolicy).to receive(:cancel?).and_return(false) }

      it 'raises en policy error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Not authorized to cancel tickets')
      end
    end

    context 'when event not found' do
      let(:ticket_ids) { [999] }

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq("Couldn't find Ticket with 'id'=#{ticket_ids.first}")
      end
    end
  end
end
