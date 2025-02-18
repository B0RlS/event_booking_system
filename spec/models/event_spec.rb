require 'rails_helper'

RSpec.describe Event, type: :model do
  subject { build(:event) }

  let(:start_time) {}

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

      context 'when start_time is in the past' do
        subject { build(:event, start_time: 1.hour.ago) }

        it 'is not valid' do
          expect(subject).not_to be_valid
        end

        it 'adds an error on start_time' do
          subject.validate
          expect(subject.errors[:start_time]).to include('must be in the future')
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
      subject { build(:event) }

      context 'when event end time reached' do
        before { allow_any_instance_of(Event).to receive(:end_time_reached?).and_return(true) }

        it 'allows transition to finished when end_time is reached' do
          expect(subject.end_time_reached?).to be true
          subject.finish! if subject.end_time_reached?
          expect(subject.aasm.current_state).to eq(:finished)
        end
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

  describe '#increment_available_tickets!' do
    subject { create(:event, total_tickets: 100, available_tickets: 50) }

    context 'when tickets are cancelled' do
      it 'increases available_tickets count' do
        expect { subject.increment_available_tickets!(5) }
          .to change { subject.reload.available_tickets }.from(50).to(55)
      end
    end
  end

  describe '#decrement_available_tickets!' do
    subject { create(:event, total_tickets: 100, available_tickets: 50) }

    context 'when there are enough available tickets' do
      it 'reduces available_tickets count' do
        expect { subject.decrement_available_tickets!(10) }
          .to change { subject.reload.available_tickets }.from(50).to(40)
      end
    end

    context 'when there are not enough tickets' do
      it 'raises a Tickets::Errors::TicketOperationError' do
        expect { subject.decrement_available_tickets!(60) }
          .to raise_error(Tickets::Errors::TicketOperationError, 'Not enough available tickets')
      end
    end
  end

  describe 'database constraints' do
    let(:event) { create(:event, total_tickets: 100, available_tickets: 100) }

    context 'when trying to set available_tickets greater than total_tickets' do
      it 'raises an ActiveRecord::StatementInvalid error due to database constraint' do
        expect do
          event.update_column(:available_tickets, 200)
        end.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end
