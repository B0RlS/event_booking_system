FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "qwerty123" }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    role { Role.find_by(name: 'user') || association(:role, :user_role) }

    trait :manager do
      role { Role.find_by(name: 'manager') || association(:role, :manager) }
    end
  end
end
