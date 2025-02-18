require 'faker'

user_role = Role.find_or_create_by!(name: 'user') do |role|
  role.description = 'A default user with limited permissions'
end

manager_role = Role.find_or_create_by!(name: 'manager') do |role|
  role.description = 'A manager with elevated permissions'
end

puts "✅ Default roles created: #{Role.pluck(:name).join(', ')}"

users = []
managers = []

3.times do
  users << User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    role: user_role
  )
end

2.times do
  managers << User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    role: manager_role
  )
end

puts "✅ Users created: #{User.pluck(:email).join(', ')}"

events = []

5.times do
  manager = managers.sample
  start_time = Faker::Time.forward(days: rand(5..30))
  end_time = start_time + rand(2..6).hours
  total_tickets = rand(50..200)
  available_tickets = rand(1..total_tickets)

  event = Event.create!(
    name: Faker::Book.title,
    description: Faker::Lorem.paragraph,
    location: Faker::Address.city,
    start_time: start_time,
    end_time: end_time,
    total_tickets: total_tickets,
    available_tickets: available_tickets,
    ticket_price_cents: rand(1000..5000),
    currency: %w[USD EUR GBP].sample,
    rate: rand(0.8..1.2),
    created_by: manager.id
  )
  events << event
end

puts "✅ Events created: #{Event.pluck(:name).join(', ')}"

20.times do
  user = users.sample
  event = events.sample
  state = %w[pending booked cancelled].sample

  next if event.available_tickets.zero? && state == 'booked'

  Ticket.create!(
    user: user,
    event: event,
    price_cents: event.ticket_price_cents,
    currency: event.currency,
    state: state,
    booked_at: (state == 'booked' ? Time.current : nil),
    cancelled_at: (state == 'cancelled' ? Time.current : nil)
  )
end

puts "✅ Tickets created: #{Ticket.count}"
puts "🎉 Seeding complete!"
