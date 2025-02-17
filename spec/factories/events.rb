FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "Event #{n}: #{Faker::Lorem.words(number: 3).join(' ')}" }
    description         { Faker::Lorem.paragraph }
    location            { Faker::Address.city }
    start_time          { Faker::Time.forward(days: 7, period: :morning) }
    end_time            { start_time + 2.hours }
    total_tickets       { Faker::Number.between(from: 50, to: 200) }
    available_tickets   { total_tickets }
    ticket_price_cents  { Faker::Number.between(from: 1000, to: 10_000) }
    currency            { 'USD' }
    rate                { Faker::Number.decimal(l_digits: 1, r_digits: 1) }
    association :creator, factory: :user

    trait :finished do
      after(:create) do |event|
        event.start_time = Faker::Time.backward(days: 7, period: :morning)
        event.end_time = event.start_time + 2.hours
        event.save!(validate: false)
        event.finish! if event.end_time_reached?
      end
    end

    trait :cancelled do
      after(:create) do |event|
        event.start_time = Time.current + 1.day
        event.end_time = Time.current + 2.days
        event.save!
        event.cancel!
      end
    end
  end
end
