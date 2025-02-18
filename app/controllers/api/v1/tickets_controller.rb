module Api
  module V1
    class TicketsController < BaseController
      def index
        render json: Queries::Ticket.by_user(current_user)
      end

      def show
        ticket = Queries::Ticket.find(params[:id])
        authorize ticket, :show?
        render json: ticket
      end

      def create
        result = Tickets::Booking.call(params[:event_id], current_user, params[:quantity].to_i)
        if result.success?
          render json: result.data, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        result = Tickets::Cancellation.call([params[:id]], current_user)
        if result.success?
          render json: { message: 'Ticket successfully cancelled' }
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
