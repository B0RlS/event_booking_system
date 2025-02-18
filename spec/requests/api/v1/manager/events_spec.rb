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

    it 'returns unprocessable entity for invalid params' do
      post '/api/v1/manager/events', params: { name: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['errors'].join).to eq(error_message)
    end
  end

  describe 'PATCH /api/v1/manager/events/:id' do
    it 'updates the event when the manager is the creator' do
      patch "/api/v1/manager/events/#{event.id}", params: { name: 'Updated Name' }
      expect(response).to have_http_status(:ok)
      expect(event.reload.name).to eq('Updated Name')
    end

    it 'returns forbidden when a manager tries to update another manager’s event' do
      patch "/api/v1/manager/events/#{other_event.id}", params: { name: 'Updated Name' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(json['errors'].join).to eq('Not authorized to update event')
    end

    it 'returns not found for a non-existent event' do
      patch '/api/v1/manager/events/999999', params: { name: 'Updated Name' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(json['errors'].join).to eq("Couldn't find Event with 'id'=999999")
    end
  end

  describe 'DELETE /api/v1/manager/events/:id' do
    it 'cancels the event when the manager is the creator' do
      delete "/api/v1/manager/events/#{event.id}"
      expect(response).to have_http_status(:ok)
      expect(event.reload.state).to eq('cancelled')
    end

    it 'returns forbidden when a manager tries to cancel another manager’s event' do
      delete "/api/v1/manager/events/#{other_event.id}"
      expect(response).to have_http_status(:unprocessable_content)
      expect(json['errors'].join).to eq('Not authorized to cancel event')
    end

    it 'returns not found for a non-existent event' do
      delete '/api/v1/manager/events/999999'
      expect(response).to have_http_status(:unprocessable_content)
      expect(json['errors'].join).to eq("Couldn't find Event with 'id'=999999")
    end
  end

  describe 'GET /api/v1/manager/events/:event_id/tickets' do
    let!(:booked_ticket) { create(:ticket, :booked, event: event) }
    let!(:other_booked_ticket) { create(:ticket, :booked, event: other_event) }

    it 'retrieves all booked and cancelled tickets for the manager’s own event' do
      get "/api/v1/manager/events/#{event.id}/tickets"
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(1)
      expect(json.first['event_id']).to eq(event.id)
    end

    it 'returns forbidden when trying to access tickets for another manager’s event' do
      get "/api/v1/manager/events/#{other_event.id}/tickets"
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns not found for a non-existent event' do
      get '/api/v1/manager/events/999999/tickets'
      expect(response).to have_http_status(:not_found)
    end
  end
end
