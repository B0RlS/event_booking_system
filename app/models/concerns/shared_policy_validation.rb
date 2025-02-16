module SharedPolicyValidation
  extend ActiveSupport::Concern

  def validate_policy!(condition, error_message)
    raise Users::Errors::UserPolicyError, error_message unless condition
  end
end
