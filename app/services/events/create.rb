module Events
  class Create
    extend Callable
    include SharedPolicyValidation
    include SharedValidations

    def initialize(params, user)
      @params = params
      @user = user
    end

    def call
      validate!
      event = Event.new(params.merge(creator: user, state: 'active'))
      raise Events::Errors::EventCreationError, event.errors.full_messages.join(', ') unless event.save

      ServiceResult.new(success: true, data: event)
    rescue Users::Errors::UserPolicyError, Events::Errors::EventCreationError, StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :params, :user

    def validate!
      validate_policy!(EventPolicy.new(user, nil).create?, 'Not authorized to create event')
      validate_user!
      validate_required_event_params!(params)
    end
  end
end
