# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# Create default roles if they do not already exist
user_role = Role.find_or_create_by!(name: 'user') do |role|
  role.description = 'A default user with limited permissions'
end

manager_role = Role.find_or_create_by!(name: 'manager') do |role|
  role.description = 'A manager with elevated permissions'
end

puts "Default roles created: #{Role.pluck(:name).join(', ')}"

# Create sample users if they do not already exist
# We use Devise's secure password and FactoryBot-like attributes here
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
