FactoryBot.define do
  factory :ticket do
    association :user
    association :event
    quantity { Faker::Number.between(from: 1, to: 5) }
    price_cents { event.ticket_price_cents }
    currency { event.currency }
    state { 'pending' }
    booked_at { nil }
    cancelled_at { nil }

    trait :booked do
      state { 'booked' }
      # Instead of setting booked_at here, we rely on the after callback of the confirm event.
      # However, for tests that need a booked ticket already, we can set it explicitly.
      booked_at { Time.current }
      cancelled_at { nil }
    end

    trait :cancelled do
      state { 'cancelled' }
      cancelled_at { Time.current }
    end

    trait :refunded do
      state { 'refunded' }
      booked_at { Time.current }
      cancelled_at { nil }
    end
  end
end
