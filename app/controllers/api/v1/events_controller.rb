module Api
  module V1
    class EventsController < BaseController
      skip_before_action :authenticate_user!, only: %i[index show]

      def index
        events = Queries::Event.cached_all_with_includes
        render json: decorate_response(events)
      end

      def show
        event = Queries::Event.cached_find(params[:id])
        render json: decorate_response(event)
      end
    end
  end
end
