require 'rails_helper'

RSpec.describe EventPolicy, type: :policy do
  subject { described_class.new(user, event) }

  let(:manager) { create(:user, :manager) }
  let(:user) { manager }
  let(:regular_user) { create(:user) }
  let(:event) { create(:event, creator: manager) }

  describe '#create?' do
    context 'when user is a manager' do
      it 'returns true' do
        expect(subject.create?).to be_truthy
      end
    end

    context 'when user is a regular user' do
      let(:user) { regular_user }

      it 'returns false' do
        expect(subject.create?).to be_falsey
      end
    end

    context 'when user is nil' do
      let(:user) { nil }

      it 'returns false' do
        expect(subject.create?).to be_falsey
      end
    end
  end

  describe '#update?' do
    context 'when user is the creator (manager)' do
      it 'returns true' do
        expect(subject.update?).to be_truthy
      end
    end

    context 'when user is a manager but not the creator' do
      subject { described_class.new(manager, create(:event, creator: create(:user, :manager))) }

      it 'returns false' do
        expect(subject.update?).to be_falsey
      end
    end

    context 'when user is a regular user' do
      let(:user) { regular_user }

      it 'returns false' do
        expect(subject.update?).to be_falsey
      end
    end

    context 'when user is nil' do
      let(:user) { nil }

      it 'returns false' do
        expect(subject.update?).to be_falsey
      end
    end
  end

  describe '#cancel?' do
    context 'when user is the creator (manager)' do
      it 'returns true' do
        expect(subject.cancel?).to be_truthy
      end
    end

    context 'when user is a manager but not the creator' do
      subject { described_class.new(manager, create(:event, creator: create(:user, :manager))) }

      it 'returns false' do
        expect(subject.cancel?).to be_falsey
      end
    end

    context 'when user is a regular user' do
      let(:user) { regular_user }

      it 'returns false' do
        expect(subject.cancel?).to be_falsey
      end
    end

    context 'when user is nil' do
      let(:user) { nil }

      it 'returns false' do
        expect(subject.cancel?).to be_falsey
      end
    end
  end
end
