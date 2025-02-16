# This class will be used by our service objects to return a uniform result
class ServiceResult
  attr_reader :errors, :data

  def initialize(success:, data: nil, errors: [])
    @success = success
    @data = data
    @errors = Array(errors)
  end

  def success?
    @success
  end

  def failure?
    !success?
  end
end
