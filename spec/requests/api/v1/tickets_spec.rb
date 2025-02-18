require 'rails_helper'

RSpec.describe 'Api::V1::Tickets', type: :request do
  let(:user) { create(:user) }
  let(:manager) { create(:user, :manager) }
  let(:event) { create(:event, creator: manager, available_tickets: 100, total_tickets: 120) }
  let!(:booked_ticket) { create(:ticket, :booked, user: user, event: event) }
  let!(:cancelled_ticket) { create(:ticket, :cancelled, user: user, event: event) }

  before { sign_in user }

  describe 'GET /api/v1/tickets' do
    let(:expected_keys) { %w[id user_id event_id price status booked_at cancelled_at] }

    it 'returns only the tickets of the logged-in user', :aggregate_failures do
      get '/api/v1/tickets'
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(2)
      expect(json.map { |tikcet| tikcet['id'] }).to match_array([booked_ticket.id, cancelled_ticket.id])
      expect(json.first.keys).to match_array(expected_keys)
    end
  end

  describe 'GET /api/v1/tickets/:id' do
    context 'when the user owns the ticket' do
      it 'returns the ticket', :aggregate_failures do
        get "/api/v1/tickets/#{booked_ticket.id}"
        expect(response).to have_http_status(:ok)
        expect(json['id']).to eq(booked_ticket.id)
      end
    end

    context 'when the user does not own the ticket' do
      let(:other_user) { create(:user) }
      let(:other_ticket) { create(:ticket, user: other_user, event: event) }

      it 'returns forbidden' do
        get "/api/v1/tickets/#{other_ticket.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when ticket does not exist' do
      it 'returns not found' do
        get '/api/v1/tickets/999999'
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/events/:event_id/tickets' do
    let(:valid_params) { { quantity: 2 } }

    it 'books tickets for the user', :aggregate_failures do
      expect { post "/api/v1/events/#{event.id}/tickets", params: valid_params }.to change(Ticket, :count).by(2)
      expect(response).to have_http_status(:created)
    end

    it 'returns unprocessable entity for invalid params', :aggregate_failures do
      post "/api/v1/events/#{event.id}/tickets", params: { quantity: 0 }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['errors'].join).to eq('Ticket count must be a positive integer')
    end

    context 'when no more available tickets does not exist' do
      let(:event) { create(:event, creator: manager, available_tickets: 0, total_tickets: 120) }

      it 'returns not found', :aggregate_failures do
        post "/api/v1/events/#{event.id}/tickets", params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors'].join).to eq('Not enough available tickets')
      end
    end
  end

  describe 'DELETE /api/v1/tickets/:id' do
    context 'when the user owns the ticket' do
      it 'cancels the ticket', :aggregate_failures do
        delete "/api/v1/tickets/#{booked_ticket.id}"
        expect(response).to have_http_status(:ok)
        expect(booked_ticket.reload.state).to eq('cancelled')
      end
    end

    context 'when the user does not own the ticket' do
      let(:other_user) { create(:user) }
      let(:other_ticket) { create(:ticket, user: other_user, event: event) }

      it 'returns forbidden error', :aggregate_failures do
        delete "/api/v1/tickets/#{other_ticket.id}"
        expect(response).to have_http_status(:unprocessable_content)
        expect(json['errors'].join).to eq('Not authorized to cancel tickets')
      end
    end

    context 'when ticket does not exist' do
      it 'returns not found error', :aggregate_failures do
        delete '/api/v1/tickets/999999'
        expect(response).to have_http_status(:unprocessable_content)
        expect(json['errors'].join).to eq("Couldn't find Ticket with 'id'=999999")
      end
    end
  end
end
