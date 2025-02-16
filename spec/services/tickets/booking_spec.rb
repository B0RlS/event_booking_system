require 'rails_helper'

RSpec.describe Tickets::Booking, type: :service do
  let(:event) do
    create(:event, total_tickets: 100, available_tickets: 80, ticket_price_cents: 5000, currency: 'USD')
  end
  let(:user) { create(:user) }

  describe '.call' do
    subject { described_class.call(event, user, quantity) }

    context 'when booking is successful' do
      let(:quantity) { 10 }

      it 'returns a successful result and updates event availability', :aggregate_failures do
        expect(subject.success?).to be true
        expect(subject.data.aasm.current_state).to eq(:booked)
        expect(event.available_tickets).to eq(70)
      end
    end

    context 'when requested quantity exceeds available tickets' do
      let(:quantity) { 90 }

      it 'returns a failure result', :aggregate_failures do
        result = subject
        expect(result.success?).to be false
        expect(result.errors.join).to include('Quantity exceeds the available tickets')
      end
    end

    context 'when ticket creation fails' do
      let(:quantity) { 10 }
      before do
        allow_any_instance_of(Ticket).to receive(:save).and_return(false)
        allow_any_instance_of(Ticket).to receive_message_chain(:errors,
                                                               :full_messages).and_return(['Ticket creation error'])
      end

      it 'returns a failure result', :aggregate_failures do
        result = subject
        expect(result.success?).to be false
        expect(result.errors.join).to match(/Ticket creation error/i)
      end
    end

    context 'when ticket confirmation fails' do
      let(:quantity) { 10 }
      let(:dummy_ticket) do
        instance_double('Ticket',
                        quantity: quantity,
                        confirm!: false,
                        errors: double(full_messages: ['Confirmation error']))
      end

      before do
        allow(Tickets::Create).to receive(:call).and_return(ServiceResult.new(success: true, data: dummy_ticket))
      end

      it 'returns a failure result', :aggregate_failures do
        result = subject
        expect(result.success?).to be false
        expect(result.errors.join).to match(/Ticket confirmation failed: Confirmation error/)
      end
    end

    context 'when event update fails during booking' do
      let(:quantity) { 10 }
      before { allow(event).to receive(:update).and_return(false) }

      it 'returns a failure result', :aggregate_failures do
        result = subject
        expect(result.success?).to be false
        expect(result.errors.join).to match(/Failed to update event availability/i)
      end
    end
  end
end
