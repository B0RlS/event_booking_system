FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    description { Faker::Lorem.sentence }

    trait :user_role do
      name { 'user' }
      description { 'A default user role with limited permissions' }
    end

    trait :manager do
      name { 'manager' }
      description { 'Manager role with elevated permissions' }
    end
  end
end
