require 'rails_helper'

RSpec.describe Tickets::Cancellation, type: :service do
  let(:event) do
    create(:event, total_tickets: 100, available_tickets: 80, ticket_price_cents: 5000, currency: 'USD')
  end
  let(:user) { create(:user) }
  let(:ticket) { create(:ticket, :booked, event: event, user: user, quantity: 5) }

  describe '.call' do
    subject { described_class.call(ticket, user) }

    context 'when cancellation is successful' do
      it 'returns a successful result and updates event availability', :aggregate_failures do
        expect(subject.success?).to be true
        cancelled_ticket = subject.data
        expect(cancelled_ticket.aasm.current_state).to eq(:cancelled)
        expect(event.available_tickets).to eq(85)
      end
    end

    context 'when ticket cancellation fails' do
      before do
        allow(ticket).to receive(:cancel!).and_return(false)
        allow(ticket).to receive_message_chain(:errors, :full_messages).and_return(['Cancellation error'])
      end

      it 'returns a failure result', :aggregate_failures do
        result = subject
        expect(result.success?).to be false
        expect(result.errors.join).to match(/Cancellation error/i)
      end
    end

    context 'when event update fails during cancellation' do
      before do
        allow(ticket).to receive(:cancel!).and_return(true)
        allow(ticket.event).to receive(:update).and_return(false)
      end

      it 'returns a failure result', :aggregate_failures do
        result = subject
        expect(result.success?).to be false
        expect(result.errors.join).to match(/Failed to update event availability/i)
      end
    end
  end
end
