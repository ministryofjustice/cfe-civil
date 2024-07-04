source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "> 7.1", "< 7.2"
# Use postgresql as the database for Active Record
# pg 1.5 introduces a deprecation warning that hasn't been fixed in Rails yet
gem "pg", "< 1.6"
# Use Puma as the app server
gem "puma", "~> 6.4"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem "faraday", "~> 1.10"

gem "prometheus-client"

gem "sentry-rails", ">= 5.18.0"
gem "sentry-ruby"

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

gem "business", "~> 2.3"
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem "date_validator"

gem "api_error_handler"
gem "json-schema", "~> 4.3.0"

# Seeding tools
gem "dibber"

# Adds Statistical methods to objects such as arrays
gem "descriptive_statistics", require: "descriptive_statistics/safe"

# Required following upgrade to ruby 3.1.0
gem "net-imap"
gem "net-pop"
gem "net-smtp"

gem "rswag-api"
gem "rswag-ui"

gem "exception_notification"
gem "govuk_notify_rails", "~> 2.2.0"

# needed for diffing in re-runner tool
gem "hashdiff"

gem "lograge"

group :development, :test do
  gem "awesome_print"
  gem "bullet"
  gem "dotenv-rails", ">= 2.8.1"
  gem "factory_bot_rails", ">= 6.2.0"
  gem "faker"
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "pry-byebug"
  gem "rack-mini-profiler", require: false
  gem "rspec_junit_formatter"
  gem "rspec-rails", "~> 6.1"
  gem "rswag-specs"
  gem "rubocop-govuk", ">= 5.0.0", require: false
  gem "rubocop-performance"

  # download spreadsheets
  gem "google_drive", ">= 3.0.7"
  # parse spreadsheets
  gem "roo", "~> 2.10.0"

  # This is needed to allow IntelliJ to run cucumber scenarios individually without producing
  # strange errors and not running the feature.
  gem "spring"
  gem "undercover"
end

group :development do
  gem "guard"
  gem "guard-bundler"
  gem "guard-cucumber"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "guard-shell"
  gem "listen", ">= 3.0.5", "< 3.10"
  gem "pry-rescue"
  gem "pry-stack_explorer"
end

group :test do
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "simplecov-lcov"
  gem "simplecov-rcov"
  gem "super_diff"
  gem "vcr"
  gem "webmock", ">= 3.13.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data"
