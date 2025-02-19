module Events
  class Creation < ApplicationService
    def initialize(params, user)
      super()
      @params = params
      @user = user
    end

    def call
      validate!
      event = Event.new(params.merge(creator: user, state: 'active'))
      raise Events::Errors::EventCreationError, event.errors.full_messages.join(', ') unless event.save

      clear_event_cache(event.id)
      ServiceResult.new(success: true, data: event)
    rescue Users::Errors::UserPolicyError, Events::Errors::EventCreationError, StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :params, :user

    def validate!
      validate_policy!(EventPolicy.new(user, nil).create?, 'Not authorized to create event')
      validate_required_event_params!(params)
    end

      def validate_required_event_params!(params)
      missing = Event::REQUIRED_KEYS.select { |k| params[k].blank? }

      raise Events::Errors::EventOperationError, "Missing event parameters: #{missing.join(', ')}" if missing.any?
    end
  end
end
