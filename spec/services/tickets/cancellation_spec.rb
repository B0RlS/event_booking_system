require 'rails_helper'

RSpec.describe Tickets::Cancellation, type: :service do
  subject { described_class.call(event, tickets, user) }

  let(:event) { create(:event, total_tickets: 100, available_tickets: 80, ticket_price_cents: 5000, currency: 'USD') }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:other_event) { create(:event) }

  let(:tickets) do
    [
      create(:ticket, :booked, event: event, user: user),
      create(:ticket, :booked, event: event, user: user),
      create(:ticket, :booked, event: event, user: user)
    ]
  end

  describe '.call' do
    context 'when cancellation is successful' do
      it 'returns a successful result and updates event availability', :aggregate_failures do
        expect(subject.success?).to be true
        expect(subject.data.all?(&:cancelled?)).to be true
        expect(event.available_tickets).to eq(83)
      end
    end

    context 'when some tickets do not belong to the event' do
      let(:tickets) do
        [
          create(:ticket, :booked, event: event, user: user),
          create(:ticket, :booked, event: other_event, user: user)
        ]
      end

      it 'raises an error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Some tickets do not belong to the specified event')
      end
    end

    context 'when tickets do not belong to the user' do
      let(:tickets) do
        [
          create(:ticket, :booked, event: event, user: user),
          create(:ticket, :booked, event: event, user: other_user)
        ]
      end

      before { allow_any_instance_of(TicketPolicy).to receive(:cancel?).and_return(true) }

      it 'raises an error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Some tickets do not belong to the user')
      end
    end

    context 'when some tickets are already cancelled' do
      let(:tickets) do
        [
          create(:ticket, :booked, event: event, user: user),
          create(:ticket, :cancelled, event: event, user: user)
        ]
      end

      before { allow_any_instance_of(TicketPolicy).to receive(:cancel?).and_return(true) }

      it 'raises an error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Some tickets are already cancelled')
      end
    end

    context 'when ticket cancellation fails' do
      before do
        allow(tickets.first).to receive(:cancel!).and_return(false)
        allow(tickets.first).to receive_message_chain(:errors, :full_messages)
          .and_return(['Cancellation error'])
      end

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Ticket cancellation failed: Cancellation error')
      end
    end

    context 'when user can not cancel tickets' do
      before { allow_any_instance_of(TicketPolicy).to receive(:cancel?).and_return(false) }

      it 'raises en policy error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Not authorized to cancel tickets')
      end
    end
  end
end
