require 'rails_helper'

RSpec.describe Tickets::Booking, type: :service do
  subject { described_class.call(event_id, user, ticket_count) }

  let(:event) do
    create(:event, total_tickets: 100, available_tickets: 80,
                   ticket_price_cents: 5000, currency: 'USD')
  end
  let(:event_id) { event.id }
  let(:user) { create(:user) }
  let(:ticket_count) { 10 }

  describe '.call' do
    context 'when booking is successful' do
      it 'returns a successful result and updates event availability', :aggregate_failures do
        expect(subject.success?).to be true
        tickets = subject.data
        expect(tickets.size).to eq(10)
        expect(tickets).to all(satisfy { |ticket| ticket.aasm.current_state == :booked })
        expect(event.reload.available_tickets).to eq(70)
      end
    end

    context 'when requested count exceeds available tickets' do
      let(:ticket_count) { 90 }

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Not enough available tickets')
      end
    end

    context 'when ticket creation fails' do
      before do
        allow_any_instance_of(Ticket).to receive(:save).and_return(false)
        allow_any_instance_of(Ticket).to receive_message_chain(:errors, :full_messages)
          .and_return(['Ticket creation error'])
      end

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Ticket creation error')
      end
    end

    context 'when ticket confirmation fails' do
      let(:dummy_ticket) do
        instance_double('Ticket',
                        aasm: double(current_state: :pending),
                        errors: double(full_messages: ['Confirmation error']),
                        confirm!: false)
      end
      before do
        allow(Tickets::Create).to receive(:call).and_return(ServiceResult.new(success: true, data: dummy_ticket))
      end

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Ticket confirmation failed: Confirmation error')
      end
    end

    context 'when ticket count is not a positive integer' do
      let(:ticket_count) { -5 }

      it 'raises an error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Ticket count must be a positive integer')
      end
    end

    context 'when user can not book tickets' do
      before { allow_any_instance_of(TicketPolicy).to receive(:book?).and_return(false) }

      it 'raises en policy error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Not authorized to book tickets')
      end
    end

    context 'when user is invalid' do
      let(:user) { build_stubbed(:user, role: nil) }

      it 'raises en policy error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('User is invalid')
      end
    end

    context 'when event not found' do
      let(:event_id) { 999 }

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq("Couldn't find Event with 'id'=#{event_id}")
      end
    end
  end
end
