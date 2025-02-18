module Api
  module V1
    module Manager
      class EventsController < BaseController
        def create
          result = Events::Create.call(event_params, current_user)
          if result.success?
            render json: result.data, status: :created
          else
            render json: { errors: result.errors }, status: :unprocessable_entity
          end
        end

        def update
          result = Events::Update.call(params[:id], event_params, current_user)
          if result.success?
            render json: result.data
          else
            render json: { errors: result.errors }, status: :unprocessable_entity
          end
        end

        def destroy
          result = Events::Cancellation.call(params[:id], current_user)
          if result.success?
            render json: { message: 'Event successfully cancelled' }
          else
            render json: { errors: result.errors }, status: :unprocessable_entity
          end
        end

        private

        def event_params
          params.permit(:name, :description, :location, :start_time, :end_time, :total_tickets, :ticket_price_cents,
                        :available_tickets, :currency, :rate)
        end
      end
    end
  end
end
