class EventPolicy
  attr_reader :user, :event

  def initialize(user, event)
    @user = user
    @event = event
  end

  def create?
    user.present? && user.role.name == 'manager'
  end

  def update?
    user.present? && user.role.name == 'manager' && event.creator == user
  end

  def cancel?
    user.present? && user.role.name == 'manager' && event.creator == user
  end
end
