# db/seeds.rb

# Create default roles if they do not already exist
user_role = Role.find_or_create_by!(name: 'user') do |role|
  role.description = 'A default user with limited permissions'
end

manager_role = Role.find_or_create_by!(name: 'manager') do |role|
  role.description = 'A manager with elevated permissions'
end

puts "Default roles: #{Role.pluck(:name).join(', ')}"

# Create sample users if they do not already exist
if User.count.zero?
  User.create!(
    email: 'user@example.com',
    password: 'password',
    first_name: 'Alice',
    last_name: 'Smith',
    role: user_role
  )

  User.create!(
    email: 'manager@example.com',
    password: 'password',
    first_name: 'Bob',
    last_name: 'Johnson',
    role: manager_role
  )

  User.create!(
    email: 'another_user@example.com',
    password: 'password',
    first_name: 'Charlie',
    last_name: 'Brown',
    role: user_role
  )

  puts "Sample users created: #{User.pluck(:email).join(', ')}"
else
  puts "Users already exist in the database."
end

# Create sample events if none exist
if Event.count.zero?
  # Use the manager user as the creator of events.
  manager = User.find_by(email: 'manager@example.com')
  unless manager
    puts "Manager user not found. Please ensure that a manager user exists."
    exit
  end

  Event.create!(
    name: 'Ruby Conference',
    description: 'A conference about Ruby on Rails and related technologies.',
    location: 'San Francisco, CA',
    start_time: 1.week.from_now,
    end_time: 1.week.from_now + 2.hours,
    total_tickets: 100,
    available_tickets: 100,
    ticket_price_cents: 5000,
    currency: 'USD',
    rate: 1.0,
    created_by: manager.id
  )

  Event.create!(
    name: 'Tech Meetup',
    description: 'A local meetup for tech enthusiasts.',
    location: 'New York, NY',
    start_time: 2.weeks.from_now,
    end_time: 2.weeks.from_now + 3.hours,
    total_tickets: 50,
    available_tickets: 50,
    ticket_price_cents: 3000,
    currency: 'USD',
    rate: 1.0,
    created_by: manager.id
  )

  puts "Sample events created: #{Event.pluck(:name).join(', ')}"
else
  puts "Events already exist in the database."
end
