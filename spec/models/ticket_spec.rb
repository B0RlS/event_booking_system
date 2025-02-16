require 'rails_helper'

RSpec.describe Ticket, type: :model do
  subject { build(:ticket) }

  let(:event) { create(:event, total_tickets: 100, available_tickets: 80) }

  describe 'validations' do
    context 'basic validations' do
      it { is_expected.to validate_presence_of(:price_cents) }
      it { is_expected.to validate_numericality_of(:price_cents).only_integer.is_greater_than_or_equal_to(0) }

      it { is_expected.to validate_presence_of(:currency) }
      it do
        is_expected.to validate_inclusion_of(:currency)
          .in_array(%w[USD EUR GBP])
          .with_message(/is not a valid currency/)
      end
    end

    context 'custom state-dependent validations' do
      context 'when state is pending' do
        context 'with booked_at set' do
          subject { build(:ticket, state: 'pending', booked_at: Time.current, cancelled_at: nil) }

          it 'is invalid if booked_at is set for pending tickets', :aggregate_failures do
            expect(subject).not_to be_valid
            subject.validate
            expect(subject.errors[:base]).to include('Timestamps should not be set for pending tickets')
          end
        end

        context 'with cancelled_at set' do
          subject { build(:ticket, state: 'pending', cancelled_at: Time.current, booked_at: nil) }

          it 'is invalid if cancelled_at is set for pending tickets', :aggregate_failures do
            expect(subject).not_to be_valid
            subject.validate
            expect(subject.errors[:base]).to include('Timestamps should not be set for pending tickets')
          end
        end

        context 'with no timestamps set' do
          subject { build(:ticket, state: 'pending', booked_at: nil, cancelled_at: nil) }

          it 'is valid' do
            expect(subject).to be_valid
          end
        end
      end

      context 'when state is booked' do
        subject { create(:ticket, :booked) }
        it 'is valid when booked_at is present and cancelled_at is nil' do
          expect(subject).to be_valid
        end

        context 'when booked_at is missing' do
          before { subject.update(booked_at: nil) }

          it 'is invalid if booked_at is missing for booked tickets' do
            subject.validate
            expect(subject.errors[:booked_at]).to include('must be present when ticket is booked')
          end
        end

        context 'when cancelled_at is set' do
          before { subject.update(cancelled_at: Time.current) }

          it 'is invalid if cancelled_at is present for booked tickets' do
            subject.validate
            expect(subject.errors[:cancelled_at]).to include('must not be set when ticket is booked')
          end
        end
      end

      context 'when state is cancelled' do
        subject { create(:ticket, :cancelled) }

        it 'is valid when cancelled_at is present' do
          expect(subject).to be_valid
        end

        context 'when cancelled_at is missing' do
          before { subject.update(cancelled_at: nil) }

          it 'is invalid if cancelled_at is missing for cancelled tickets' do
            subject.validate
            expect(subject.errors[:cancelled_at]).to include('must be present when ticket is cancelled')
          end
        end
      end

      context 'when state is refunded' do
        subject { build(:ticket, :refunded) }

        it 'is valid as long as the state is correctly set' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe 'associations' do
    subject { build(:ticket) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
  end

  describe 'state machine transitions' do
    subject { create(:ticket) }

    context 'initial state' do
      it 'has pending as the initial state' do
        expect(subject.aasm.current_state).to eq(:pending)
      end
    end

    context 'transitioning to booked' do
      it 'transitions from pending to booked when confirm! is called', :aggregate_failures do
        subject.confirm!
        expect(subject.aasm.current_state).to eq(:booked)
        expect(subject.booked_at).not_to be_nil
      end
    end

    context 'transitioning to cancelled' do
      context 'from pending state' do
        subject { create(:ticket, state: 'pending', booked_at: nil, cancelled_at: nil) }

        it 'raises an error when refund! is called', :aggregate_failures do
          expect { subject.cancel! }.to raise_error(AASM::InvalidTransition)
          expect(subject.aasm.current_state).to eq(:pending)
        end
      end

      context 'from booked state' do
        subject { create(:ticket, :booked) }

        it 'transitions from booked to cancelled when cancel! is called', :aggregate_failures do
          subject.cancel!
          expect(subject.aasm.current_state).to eq(:cancelled)
          expect(subject.cancelled_at).not_to be_nil
        end
      end
    end

    context 'transitioning to refunded' do
      context 'from booked state' do
        subject { create(:ticket, :booked) }

        it 'transitions from booked to refunded when refund! is called', :aggregate_failures do
          subject.refund!
          expect(subject.aasm.current_state).to eq(:refunded)
        end
      end

      context 'from pending state' do
        subject { build(:ticket, state: 'pending') }

        it 'raises an error when refund! is called', :aggregate_failures do
          expect { subject.refund! }.to raise_error(AASM::InvalidTransition)
          expect(subject.aasm.current_state).to eq(:pending)
        end
      end
    end
  end
end
