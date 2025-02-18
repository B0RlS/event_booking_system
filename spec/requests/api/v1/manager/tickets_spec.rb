require 'rails_helper'

RSpec.describe 'Api::V1::Manager::Tickets', type: :request do
  let(:manager) { create(:user, :manager) }
  let(:other_manager) { create(:user, :manager) }

  let(:event) { create(:event, creator: manager) }
  let(:other_event) { create(:event, creator: other_manager) }

  let!(:booked_ticket) { create(:ticket, :booked, event: event) }
  let!(:cancelled_ticket) { create(:ticket, :cancelled, event: event) }
  let!(:other_booked_ticket) { create(:ticket, :booked, event: other_event) }

  before { sign_in manager }

  describe 'GET /api/v1/manager/events/:event_id/tickets' do
    context 'when the manager owns the event' do
      it 'retrieves all booked and cancelled tickets' do
        get "/api/v1/manager/events/#{event.id}/tickets"
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(2)
        expect(json.map { |tikcet| tikcet['id'] }).to match_array([booked_ticket.id, cancelled_ticket.id])
      end
    end

    context 'when the manager does not own the event' do
      it 'returns forbidden' do
        get "/api/v1/manager/events/#{other_event.id}/tickets"
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when event does not exist' do
      it 'returns not found' do
        get '/api/v1/manager/events/999999/tickets'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
