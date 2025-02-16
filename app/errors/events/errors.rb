module Events
  module Errors
    class EventOperationError < StandardError; end
    class EventCreationError < EventsOperationError; end
    class EventCancellationError < EventsOperationError; end
    class EventUpdateError < EventsOperationError; end
  end
end
