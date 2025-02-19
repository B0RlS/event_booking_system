class ApplicationService
  include SharedPolicyValidation

  def self.call(*args, &block)
    new(*args, &block).call
  end

  private

  def clear_event_cache(event_id)
    Rails.cache.delete("events/#{event_id}")
    Rails.cache.delete('events/all')
  end
end
