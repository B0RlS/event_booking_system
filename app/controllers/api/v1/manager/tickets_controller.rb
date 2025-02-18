module Api
  module V1
    module Manager
      class TicketsController < BaseController
        def index
          event = Queries::Event.find(params[:event_id])
          authorize event, :manage?

          render json: Queries::Ticket.by_event(event).booked_and_cancelled
        end
      end
    end
  end
end
