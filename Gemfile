source "https://rubygems.org"

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.5", ">= 7.1.5.1"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"

gem "jbuilder"

# Authentication
gem 'devise'

# State Machines
gem 'aasm'

# Event Sourcing / Domain Events
gem 'dry-events'

gem 'pundit'
gem 'after_commit_everywhere'

# ActiveModel Serializers for Presentation Layer
gem 'active_model_serializers'

gem 'redis'
gem 'pry'
gem 'pry-rails'
gem "draper", "~> 4.0"
gem 'money-rails', '~> 1.12'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'faker'
  gem 'pry-byebug'
  gem 'dry-validation'
end

group :development do
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

gem 'dotenv-rails', groups: [:development, :test]
