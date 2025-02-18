module Api
  module V1
    module Manager
      class TicketsController < BaseController
        def index
          event = Queries::Event.find(params[:event_id])
          authorize event, :manage?

          tickets = Queries::Ticket.by_event(event).booked_and_cancelled
          render json: decorate_response(tickets)
        end
      end
    end
  end
end
