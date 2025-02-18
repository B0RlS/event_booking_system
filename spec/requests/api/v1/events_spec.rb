require 'rails_helper'

RSpec.describe 'Api::V1::Events', type: :request do
  let(:user) { create(:user) }
  let(:manager) { create(:user, :manager) }
  let(:manager2) { create(:user, :manager) }
  let!(:event1) { create(:event, creator: manager) }
  let!(:event2) { create(:event, creator: manager2) }

  describe 'GET /api/v1/events' do
    let(:expected_keys) do
      %w[id name description location start_time end_time state tickets_available tickets_total price created_by]
    end

    it 'returns all events for public access', :aggregate_failures do
      get '/api/v1/events'
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(2)
      expect(json.first.keys).to match_array(expected_keys)
    end
  end

  describe 'GET /api/v1/events/:id' do
    context 'when event exists' do
      it 'returns the event', :aggregate_failures do
        get "/api/v1/events/#{event1.id}"
        expect(response).to have_http_status(:ok)
        expect(json['id']).to eq(event1.id)
      end
    end

    context 'when event does not exist' do
      it 'returns not found', :aggregate_failures do
        get '/api/v1/events/9999'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
