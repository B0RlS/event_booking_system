module Events
  class Update < ApplicationService
    def initialize(event_id, params, user)
      super()
      @event_id = event_id
      @params = params
      @user = user
    end

    def call
      validate!
      event.update!(params)
      clear_event_cache(event.id)
      ServiceResult.new(success: true, data: event)
    rescue ActiveRecord::RecordInvalid, StandardError => e
      ServiceResult.new(success: false, errors: [e.message])
    end

    private

    attr_reader :event_id, :params, :user

    def validate!
      validate_policy!(EventPolicy.new(user, event).update?, 'Not authorized to update event')
    end

    def event
      @event ||= Queries::Event.cached_find(event_id)
    end

    def clear_event_cache(event_id)
      Rails.cache.delete("events/#{event_id}")
      Rails.cache.delete('events/all')
    end
  end
end
