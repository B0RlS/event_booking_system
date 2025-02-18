require 'rails_helper'

RSpec.describe 'Api::V1::Events', type: :request do
  let(:user) { create(:user) }
  let(:manager) { create(:user, :manager) }
  let(:manager2) { create(:user, :manager) }
  let!(:event1) { create(:event, creator: manager) }
  let!(:event2) { create(:event, creator: manager2) }

  describe 'GET /api/v1/events' do
    it 'returns all events for public access' do
      get '/api/v1/events'
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(2)
    end
  end

  describe 'GET /api/v1/events/:id' do
    context 'when event exists' do
      it 'returns the event' do
        get "/api/v1/events/#{event1.id}"
        expect(response).to have_http_status(:ok)
        expect(json['id']).to eq(event1.id)
      end
    end

    context 'when event does not exist' do
      it 'returns not found' do
        get '/api/v1/events/9999'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
