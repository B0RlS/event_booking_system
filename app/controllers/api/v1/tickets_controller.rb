module Api
  module V1
    class TicketsController < BaseController
      def index
        tickets = Queries::Ticket.cached_by_user(current_user)
        render json: decorate_response(tickets)
      end

      def show
        ticket = Queries::Ticket.cached_find(params[:id])
        authorize ticket, :show?
        render json: decorate_response(ticket)
      end

      def create
        result = Tickets::Booking.call(params[:event_id], current_user, params[:quantity].to_i)
        if result.success?
          render json: decorate_response(result.data), status: :created
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
