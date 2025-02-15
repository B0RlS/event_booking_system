FactoryBot.define do
  factory :role do
    name { 'user' }
    description { 'A regular user role' }

    trait :manager do
      name { 'manager' }
      description { 'Manager role with elevated permissions' }
    end
  end
end
