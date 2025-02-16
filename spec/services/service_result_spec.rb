require 'rails_helper'

RSpec.describe ServiceResult, type: :model do
  subject { described_class.new(success: success, data: data, errors: errors) }

  describe '.new' do
    context 'when success is true' do
      let(:success) { true }
      let(:data)    { { foo: 'bar' } }
      let(:errors)  { [] }

      it 'returns success?' do
        expect(subject.success?).to be true
      end

      it 'stores the provided data' do
        expect(subject.data).to eq({ foo: 'bar' })
      end
    end

    context 'when success is false' do
      let(:success) { false }
      let(:data)    { nil }
      let(:errors)  { 'Something went wrong' }

      it 'returns failure?' do
        expect(subject.failure?).to be true
      end

      it 'stores errors as an array' do
        expect(subject.errors).to eq(['Something went wrong'])
      end
    end
  end
end
