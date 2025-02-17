module Events
  module Errors
    class EventOperationError < StandardError; end
    class EventCreationError < EventOperationError; end
    class EventCancellationError < EventOperationError; end
    class EventUpdateError < EventOperationError; end
  end
end
