module Api
  module V1
    class EventsController < BaseController
      skip_before_action :authenticate_user!, only: %i[index show]

      def index
        render json: Queries::Event.all_with_includes
      end

      def show
        render json: Queries::Event.find(params[:id])
      end
    end
  end
end
