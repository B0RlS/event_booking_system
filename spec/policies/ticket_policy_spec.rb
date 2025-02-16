require 'rails_helper'

RSpec.describe TicketPolicy, type: :policy do
  subject { described_class.new(user, ticket) }

  let(:user) { create(:user) }
  let(:manager) { create(:user, :manager) }
  let(:ticket) { create(:ticket, :booked, user: user, event: create(:event)) }

  describe '#book?' do
    context 'when user is present' do
      it 'returns true' do
        expect(subject.book?).to be_truthy
      end
    end

    context 'when user is nil' do
      let(:user) { nil }
      let(:ticket) { build_stubbed(:ticket, :booked, user: user, event: create(:event)) }

      it 'returns false' do
        expect(subject.book?).to be_falsey
      end
    end
  end

  describe '#cancel?' do
    context 'when ticket belongs to the user and is booked' do
      it 'returns true' do
        expect(subject.cancel?).to be_truthy
      end
    end

    context 'when ticket does not belong to the user' do
      let(:ticket) { create(:ticket, user: manager, event: create(:event)) }

      it 'returns false' do
        expect(subject.cancel?).to be_falsey
      end
    end

    context 'when user is nil' do
      let(:user) { nil }
      let(:ticket) { build_stubbed(:ticket, :booked, user: user, event: create(:event)) }

      it 'returns false' do
        expect(subject.cancel?).to be_falsey
      end
    end

    context 'when ticket is not booked' do
      let(:ticket) { create(:ticket, user: user, event: create(:event)) }

      it 'returns false' do
        expect(subject.cancel?).to be_falsey
      end
    end
  end
end
