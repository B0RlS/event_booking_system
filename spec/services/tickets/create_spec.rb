require 'rails_helper'

RSpec.describe Tickets::Create, type: :service do
  subject { described_class.call(event, user, quantity) }

  let(:event) { create(:event, total_tickets: 100, available_tickets: 80, ticket_price_cents: 5000, currency: 'USD') }
  let(:user) { create(:user) }

  describe '.call' do
    context 'when ticket creation is successful' do
      let(:quantity) { 5 }

      it 'returns a successful ServiceResult with the created ticket', :aggregate_failures do
        expect(subject.success?).to be true
        ticket = subject.data
        expect(ticket.state).to eq('pending')
        expect(ticket.quantity).to eq(5)
        expect(ticket.price_cents).to eq(event.ticket_price_cents)
        expect(ticket.currency).to eq(event.currency)
        expect(ticket.event).to eq(event)
        expect(ticket.user).to eq(user)
      end
    end

    context 'when ticket creation fails' do
      let(:quantity) { 5 }
      before do
        allow_any_instance_of(Ticket).to receive(:save).and_return(false)
        allow_any_instance_of(Ticket).to receive_message_chain(:errors,
                                                               :full_messages).and_return(['Some error occurred'])
      end

      it 'raises a TicketCreationError' do
        expect { subject }.to raise_error(TicketCreationError, /Some error occurred/)
      end
    end
  end
end
