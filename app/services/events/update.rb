module Events
  class Update
    extend Callable
    include SharedPolicyValidation
    include SharedValidations

    def initialize(event, params, user)
      @event = event
      @params = params
      @user = user
    end

    def call
      validate!
      event.update!(params)
      ServiceResult.new(success: true, data: event)
    rescue ActiveRecord::RecordInvalid, StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :event, :params, :user

    def validate!
      validate_policy!(EventPolicy.new(user, event).update?, 'Not authorized to update event')
      validate_event!
      validate_user!
    end
  end
end
