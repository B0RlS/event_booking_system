FactoryBot.define do
  factory :user do
    sequence(:email) { |test_name| "user#{test_name}@example.com" }
    password { 'qwerty123' }
    first_name { 'Boris' }
    last_name  { 'Tsarikov' }
    association :role, factory: :role

    trait :manager do
      association :role, factory: %i[role manager]
    end
  end
end
