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


# module Events
#   class Cancellation
#     extend Callable
#     include SharedPolicyValidation
#     include SharedValidations

#     def initialize(event_id, user)
#       @event_id = event_id
#       @user = user
#     end

#     def call
#       validate!
#       ActiveRecord::Base.transaction do
#         event.cancel!
#         cancel_tickets!
#       end
#       ServiceResult.new(success: true, data: event)
#     rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid, StandardError => e
#       ServiceResult.new(success: false, errors: [e.message])
#     end

#     private

#     attr_reader :event_id, :user

#     def validate!
#       validate_policy!(EventPolicy.new(user, event).cancel?, 'Not authorized to cancel event')
#       validate_event!
#       validate_user!
#       validate_cancelation_for_event!
#     end

#     def event
#       @event ||= Queries::Event.find(event_id)
#     end

#     def cancel_tickets!
#       binding.pry
#       event.tickets.booked_and_pending.find_each do |ticket|
#         ticket.cancel!
#       end
#     end
#   end
# end
