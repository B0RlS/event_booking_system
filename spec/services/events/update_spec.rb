require 'rails_helper'

RSpec.describe Events::Update, type: :service do
  subject { described_class.call(event, update_params, user) }

  let(:user) { create(:user, :manager) }
  let(:event) { create(:event, name: 'Original Name', creator: user) }
  let(:update_params) { { name: 'Updated Name' } }

  describe '.call' do
    context 'when update is successful and authorized' do
      it 'returns a successful result and updates the event' do
        expect(subject.success?).to be true
        expect(subject.data.name).to eq('Updated Name')
      end
    end

    context 'when update is not authorized' do
      let(:user) { create(:user) }

      it 'returns a failure result with a not authorized error' do
        expect(subject.success?).to be false
        expect(subject.errors.join).to eq('Not authorized to update event')
      end
    end

    context 'when event update fails' do
      before do
        allow_any_instance_of(Event).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(event))
      end

      it 'returns a failure result with error messages' do
        expect(subject.success?).to be false
        expect(subject.errors.join).to match(/Validation failed/)
      end

      context 'when data is invalid' do
        let(:update_params) { { name: nil } }

        it 'returns a failure result with AR validation error messages' do
          expect(subject.success?).to be false
          expect(subject.errors.join).to match(/Validation failed/)
        end
      end
    end
  end
end
