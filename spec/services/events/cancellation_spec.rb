require 'rails_helper'

RSpec.describe Events::Cancellation, type: :service do
  subject { described_class.call(event_id, user) }

  let(:user) { create(:user, :manager) }
  let(:event) { create(:event, creator: user) }
  let(:event_id) { event.id }

  describe '.call' do
    context 'when cancellation is successful and authorized' do
      it 'returns a successful result and updates event state to cancelled', :aggregate_failures do
        expect(subject.success?).to be true
        expect(subject.data.aasm.current_state).to eq(:cancelled)
      end
    end

    context 'when cancellation is not authorized' do
      let(:user) { create(:user) }

      it 'returns a failure result with a not authorized error', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Not authorized to cancel event')
      end
    end

    context 'when the event cannot be cancelled' do
      let(:event) { create(:event, :finished, creator: user) }

      it 'returns a failure result with the proper error message', :aggregate_failures do
        expect(subject.errors.join).to eq('Event must be in active state to cancel')
      end
    end

    context 'when cancelling event with booked tickets' do
      before do
        create_list(:ticket, 3, :booked, event: event, user: user)
        create_list(:ticket, 2, event: event, user: user)
      end

      it 'cancels related booked tickets' do
        expect { subject }.to change { Queries::Ticket.cancelled.count }.by(5)
        expect(event.reload.state).to eq('cancelled')
      end
    end

    context 'when event cancelation fails' do
      before { allow_any_instance_of(Event).to receive(:cancel!).and_raise(StandardError.new('Cancellation failed')) }

      it 'returns a failure result', :aggregate_failures do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Cancellation failed')
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
