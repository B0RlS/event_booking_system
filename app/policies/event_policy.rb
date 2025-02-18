class EventPolicy
  attr_reader :user, :event

  def initialize(user, event)
    @user = user
    @event = event
  end

  def show?
    true
  end

  def create?
    user.present? && user.manager?
  end

  def update?
    manage?
  end

  def cancel?
    manage?
  end

  def manage?
    user.present? && user.manager? && event.creator == user
  end
end
