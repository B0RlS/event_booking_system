require 'rails_helper'

RSpec.describe Event, type: :model do
  subject { build(:event) }

  context 'validations' do
    context 'basic presence validations' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:description) }
      it { is_expected.to validate_presence_of(:location) }
      it { is_expected.to validate_presence_of(:start_time) }
      it { is_expected.to validate_presence_of(:total_tickets) }
      it { is_expected.to validate_presence_of(:available_tickets) }
      it { is_expected.to validate_presence_of(:ticket_price_cents) }
      it { is_expected.to validate_presence_of(:currency) }
    end

    context 'numericality validations' do
      it { is_expected.to validate_numericality_of(:total_tickets).only_integer.is_greater_than(0) }
      it { is_expected.to validate_numericality_of(:available_tickets).only_integer.is_greater_than_or_equal_to(0) }
      it { is_expected.to validate_numericality_of(:ticket_price_cents).only_integer.is_greater_than_or_equal_to(0) }
    end

    context 'custom validations' do
      context 'when available_tickets exceed total_tickets' do
        subject { build(:event, total_tickets: 50, available_tickets: 60) }

        it 'is not valid' do
          expect(subject).not_to be_valid
        end

        it 'adds an error on available_tickets' do
          subject.validate
          expect(subject.errors[:available_tickets]).to include('cannot be greater than total tickets')
        end
      end

      context 'when end_time is before start_time' do
        subject { build(:event, start_time: Time.current, end_time: 1.hour.ago) }

        it 'is not valid' do
          expect(subject).not_to be_valid
        end

        it 'adds an error on end_time' do
          subject.validate
          expect(subject.errors[:end_time]).to include('must be after start time')
        end
      end

      context 'when all validations pass' do
        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:creator).class_name('User').with_foreign_key('created_by') }
    it { is_expected.to have_many(:tickets).dependent(:destroy) }
  end

  context 'state machine behavior' do
    context 'initial state' do
      it 'is active by default' do
        expect(subject.aasm.current_state).to eq(:active)
      end
    end

    context 'transitioning to finished' do
      subject { build(:event, start_time: 2.days.ago, end_time: 1.day.ago) }

      it 'allows transition to finished when end_time is reached' do
        expect(subject.end_time_reached?).to be true
        subject.finish! if subject.end_time_reached?
        expect(subject.aasm.current_state).to eq(:finished)
      end

      context 'when end_time has not been reached' do
        subject { build(:event, start_time: 1.hour.ago, end_time: 1.hour.from_now) }

        it 'does not allow transition to finished' do
          expect(subject.end_time_reached?).to be false
          expect { subject.finish! }.to raise_error(AASM::InvalidTransition)
          expect(subject.aasm.current_state).to eq(:active)
        end
      end
    end

    context 'transitioning to cancelled' do
      it 'can transition from active to cancelled' do
        subject.cancel!
        expect(subject.aasm.current_state).to eq(:cancelled)
      end
    end
  end
end
