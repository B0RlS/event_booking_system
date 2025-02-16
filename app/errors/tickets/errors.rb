module Tickets
  module Errors
    class TicketOperationError < StandardError; end
    class TicketBookingError < TicketOperationError; end
    class TicketCancellationError < TicketOperationError; end
  end
end
