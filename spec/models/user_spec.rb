require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user, :manager) }

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:role) }
  end

  describe 'associations' do
    it { should belong_to(:role) }
  end

  describe 'with valid attributes' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'without a role' do
    subject { build(:user, role: nil) }

    it 'is not valid' do
      expect(subject).not_to be_valid
    end
  end

  describe '.manager?' do
    context 'when user is a manager' do
      it 'returns false' do
        expect(subject.manager?).to be_truthy
      end
    end

    context 'when user is not a manager' do
      subject { build(:user) }

      it 'returns false' do
        expect(subject.manager?).to be_falsey
      end
    end
  end
end
