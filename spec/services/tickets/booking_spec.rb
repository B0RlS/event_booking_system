require 'rails_helper'

RSpec.describe Tickets::Booking, type: :service do
  subject { described_class.call(event, user, ticket_count) }

  let(:event) do
    create(:event, total_tickets: 100, available_tickets: 80,
                   ticket_price_cents: 5000, currency: 'USD')
  end
  let(:user) { create(:user) }

  describe '.call' do
    context 'when booking is successful' do
      let(:ticket_count) { 10 }

      it 'returns a successful result and updates event availability', :aggregate_failures do
        expect(subject.success?).to be true
        tickets = subject.data
        expect(tickets.size).to eq(10)
        expect(tickets).to all( satisfy { |t| t.aasm.current_state == :booked } )
        expect(event.available_tickets).to eq(70)
      end
    end

    context 'when requested count exceeds available tickets' do
      let(:ticket_count) { 90 }

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to match(/Not enough available tickets/i)
      end
    end

    context 'when ticket creation fails' do
      let(:ticket_count) { 10 }
      before do
        allow_any_instance_of(Ticket).to receive(:save).and_return(false)
        allow_any_instance_of(Ticket).to receive_message_chain(:errors, :full_messages)
          .and_return(['Ticket creation error'])
      end

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to match(/Ticket creation error/i)
      end
    end

    context 'when ticket confirmation fails' do
      let(:ticket_count) { 10 }
      let(:dummy_ticket) do
        instance_double('Ticket',
                        aasm: double(current_state: :pending),
                        errors: double(full_messages: ['Confirmation error']),
                        confirm!: false)
      end
      before do
        allow(Tickets::Create).to receive(:call).and_return(
          ServiceResult.new(success: true, data: dummy_ticket)
        )
      end

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to match(/Ticket confirmation failed: Confirmation error/)
      end
    end

    context 'when event update fails during booking' do
      let(:ticket_count) { 10 }
      before { allow(event).to receive(:update!).and_return(false) }

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to match(/Failed to update event availability/i)
      end
    end
  end
end
