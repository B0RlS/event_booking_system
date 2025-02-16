class TicketPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def book?
    user.present?
  end

  def cancel?
    return false unless user.present?
    if record.is_a?(Array)
      record.all? { |ticket| ticket.user == user && ticket.booked? }
    else
      record.user == user && record.booked?
    end
  end
end
