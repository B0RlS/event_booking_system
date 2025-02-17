require 'rails_helper'

RSpec.describe Events::Create, type: :service do
  subject { described_class.call(params, user) }

  let(:user) { create(:user, :manager) }
  let(:params) { valid_params }
  let(:valid_params) do
    {
      name: 'Test Event',
      description: 'An event description',
      location: 'Some Location',
      start_time: 1.day.from_now,
      end_time: 2.days.from_now,
      total_tickets: 100,
      available_tickets: 100,
      ticket_price_cents: 5000,
      currency: 'USD'
    }
  end

  describe '.call' do
    context 'with valid parameters and authorized user' do
      it 'returns a successful result and creates an event with state active' do
        result = subject
        expect(result.success?).to be true
        event = result.data
        expect(event.aasm.current_state).to eq(:active)
        expect(event.creator).to eq(user)
      end
    end

    context 'with valid parameters but unauthorized user' do
      let(:user) { create(:user) }

      it 'raises a not authorized error' do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Not authorized to create event')
      end
    end

    context 'with missing parameters' do
      let(:params) { valid_params.except(:name) }

      it 'raises an error via shared validations' do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Missing event parameters: name')
      end
    end

    context 'when event creation fails' do
      before do
        allow_any_instance_of(Event).to receive(:save).and_return(false)
        allow_any_instance_of(Event).to receive_message_chain(:errors, :full_messages)
          .and_return(['Event creation error'])
      end

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Event creation error')
      end
    end
  end
end
