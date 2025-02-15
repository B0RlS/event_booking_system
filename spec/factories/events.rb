FactoryBot.define do
  factory :event do
    name                { 'Sample Event' }
    description         { 'An event description.' }
    location            { 'Event Venue' }
    start_time          { 1.day.from_now }
    end_time            { 2.days.from_now }
    total_tickets       { 100 }
    available_tickets   { 100 }
    ticket_price_cents  { 5_000 }
    currency            { 'USD' }
    rate                { 1.0 }
    association :creator, factory: :user

    trait :finished do
      start_time { 2.days.ago }
      end_time   { 1.day.ago }
      aasm_state { 'finished' }
    end

    trait :cancelled do
      aasm_state { 'cancelled' }
    end
  end
end
