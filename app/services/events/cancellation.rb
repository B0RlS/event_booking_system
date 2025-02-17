module Events
  class Cancellation
    extend Callable
    include SharedPolicyValidation
    include SharedValidations

    def initialize(event, user)
      @event = event
      @user = user
    end

    def call
      validate!
      event.cancel!
      ServiceResult.new(success: true, data: event)
    rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid, StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :event, :user

    def validate!
      validate_policy!(EventPolicy.new(user, event).cancel?, 'Not authorized to cancel event')
      validate_event!
      validate_user!
      validate_cancelation_for_event!
    end
  end
end
