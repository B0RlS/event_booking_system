require 'rails_helper'

RSpec.describe 'Api::V1::Manager::Events', type: :request do
  let(:manager) { create(:user, :manager) }
  let(:other_manager) { create(:user, :manager) }

  let(:event) { create(:event, creator: manager) }
  let(:other_event) { create(:event, creator: other_manager) }

  before { sign_in manager }

  describe 'POST /api/v1/manager/events' do
    let(:valid_params) { attributes_for(:event) }
    let(:error_message) do
      'Missing event parameters: name, description, location, start_time, ' \
      'total_tickets, available_tickets, ticket_price_cents, currency'
    end

    it 'creates a new event' do
      expect { post '/api/v1/manager/events', params: valid_params }.to change(Event, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'returns unprocessable entity for invalid params', :aggregate_failures do
      post '/api/v1/manager/events', params: { name: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['errors'].join).to eq(error_message)
    end
  end

  describe 'PATCH /api/v1/manager/events/:id' do
    context 'when the manager is the creator' do
      it 'updates the event', :aggregate_failures do
        patch "/api/v1/manager/events/#{event.id}", params: { name: 'Updated Name' }
        expect(response).to have_http_status(:ok)
        expect(event.reload.name).to eq('Updated Name')
      end
    end

    context 'when a manager tries to update another manager’s event' do
      it 'returns forbidden error', :aggregate_failures do
        patch "/api/v1/manager/events/#{other_event.id}", params: { name: 'Updated Name' }
        expect(response).to have_http_status(:unprocessable_content)
        expect(json['errors'].join).to eq('Not authorized to update event')
      end
    end

    it 'returns not found for a non-existent event', :aggregate_failures do
      patch '/api/v1/manager/events/999999', params: { name: 'Updated Name' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(json['errors'].join).to eq("Couldn't find Event with 'id'=999999")
    end
  end

  describe 'DELETE /api/v1/manager/events/:id' do
    context 'when the manager is the creator' do
      it 'cancels the event', :aggregate_failures do
        delete "/api/v1/manager/events/#{event.id}"
        expect(response).to have_http_status(:ok)
        expect(event.reload.state).to eq('cancelled')
      end
    end

    context 'when a manager tries to cancel another manager’s event' do
      it 'returns forbidden error', :aggregate_failures do
        delete "/api/v1/manager/events/#{other_event.id}"
        expect(response).to have_http_status(:unprocessable_content)
        expect(json['errors'].join).to eq('Not authorized to cancel event')
      end
    end

    it 'returns not found for a non-existent event', :aggregate_failures do
      delete '/api/v1/manager/events/999999'
      expect(response).to have_http_status(:unprocessable_content)
      expect(json['errors'].join).to eq("Couldn't find Event with 'id'=999999")
    end
  end

  describe 'GET /api/v1/manager/events/:event_id/tickets' do
    let(:expected_keys) { %w[id user_id event_id price status booked_at cancelled_at] }

    before do
      create(:ticket, :booked, event: event)
      create(:ticket, :booked, event: other_event)
    end

    it 'retrieves all booked and cancelled tickets for the manager’s own event', :aggregate_failures do
      get "/api/v1/manager/events/#{event.id}/tickets"
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(1)
      expect(json.first.keys).to match_array(expected_keys)
      expect(json.first['event_id']).to eq(event.id)
    end

    context 'when trying to access tickets for another manager’s event' do
      it 'returns forbidden' do
        get "/api/v1/manager/events/#{other_event.id}/tickets"
        expect(response).to have_http_status(:forbidden)
      end
    end

    it 'returns not found for a non-existent event' do
      get '/api/v1/manager/events/999999/tickets'
      expect(response).to have_http_status(:not_found)
    end
  end
end
