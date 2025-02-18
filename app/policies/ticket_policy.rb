class TicketPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    record.user == user
  end

  def book?
    user.present?
  end

  def cancel?
    manage?
  end

  def manage?
    return false unless user.present?

    if record.is_a?(Array)
      record.all? { |ticket| ticket.user == user && ticket.booked? }
    else
      record.user == user && record.booked?
    end
  end
end
