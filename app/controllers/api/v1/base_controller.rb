module Api
  module V1
    class BaseController < ApplicationController
      include Pundit::Authorization
      include Devise::Controllers::Helpers

      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from Pundit::NotAuthorizedError, with: :forbidden_request

      private

      def record_not_found
        render json: { error: 'Record not found' }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
      end

      def forbidden_request
        render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
      end

      def decorate_response(resource)
        return if resource.nil?

        if resource.respond_to?(:decorate)
          resource.decorate
        elsif resource.respond_to?(:each)
          resource.each(&:decorate)
        else
          resource
        end
      end
    end
  end
end
