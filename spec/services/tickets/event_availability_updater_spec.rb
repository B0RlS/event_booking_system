require 'rails_helper'

RSpec.describe Tickets::EventAvailabilityUpdater do
  subject { described_class.call(event, delta) }

  let(:event) { create(:event, available_tickets: 10) }
  let(:delta) { 5 }

  describe '#call' do
    context 'when updating tickets successfully' do
      it 'increases available tickets' do
        expect(subject).to be_success
        expect(event.reload.available_tickets).to eq(15)
      end

      context 'when decreasing available tickets' do
        let(:delta) { -5 }

        it 'reduces available tickets' do
          expect(subject).to be_success
          expect(event.reload.available_tickets).to eq(5)
        end
      end
    end

    context 'when not enough available tickets' do
      let(:delta) { -15 }

      it 'raises EventAvailabilityError' do
        expect { subject }.to raise_error(EventAvailabilityError, 'Not enough available tickets')
      end
    end

    context 'when update fails' do
      before { allow(event).to receive(:update!).and_return(false) }

      it 'raises EventAvailabilityError' do
        expect { subject }.to raise_error(EventAvailabilityError, 'Failed to update event availability')
      end
    end
  end
end
