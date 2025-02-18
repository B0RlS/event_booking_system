module Events
  class Cancellation
    extend Callable
    include SharedPolicyValidation
    include SharedValidations

    def initialize(event_id, user)
      @event_id = event_id
      @user = user
    end

    def call
      validate!
      event.cancel!
      # TODO: cancellation all related booked tickets
      # TODO wrap to transactions
      # Maybe create auto cancellation all booked tickets after cancellation event
      ServiceResult.new(success: true, data: event)
    rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid, StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :event_id, :user

    def validate!
      validate_policy!(EventPolicy.new(user, event).cancel?, 'Not authorized to cancel event')
      validate_event!
      validate_user!
      validate_cancelation_for_event!
    end

    def event
      @event ||= Queries::Event.find(event_id)
    end
  end
end
