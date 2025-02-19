module Events
  class Cancellation < ApplicationService
    def initialize(event_id, user)
      super()
      @event_id = event_id
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

    attr_reader :event_id, :user

    def validate!
      validate_policy!(EventPolicy.new(user, event).cancel?, 'Not authorized to cancel event')
      validate_cancelation_for_event!
    end

    def event
      @event ||= Queries::Event.cached_find(event_id)
    end

    def validate_cancelation_for_event!
      raise Events::Errors::EventOperationError, 'Event must be in active state to cancel' unless event.active?
    end
  end
end
