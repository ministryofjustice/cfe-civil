source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails"
# Use postgresql as the database for Active Record
# pg 1.5 introduces a deprecation warning that hasn't been fixed in Rails yet
gem "pg", "< 1.7"
# Use Puma as the app server
gem "puma", "~> 7.2"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem "faraday", "~> 2.14"

gem "prometheus-client"

gem "sentry-rails", ">= 5.8.0"
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
gem "json-schema", "~> 6.1.0"

# Seeding tools
gem "dibber"

# Adds Statistical methods to objects such as arrays
gem "descriptive_statistics", require: "descriptive_statistics/safe"

# Required following upgrade to ruby 3.1.0
gem "net-imap", ">= 0.5.6"
gem "net-pop"
gem "net-smtp"

gem "ostruct" # needed until rswag merge PR#872
gem "rswag-api"
gem "rswag-ui"

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
  gem "byebug"
  gem "pry-byebug"
  gem "rack-mini-profiler", require: false
  gem "rspec_junit_formatter"
  gem "rspec-rails", "~> 8.0"
  gem "rswag-specs"
  gem "rubocop-govuk", require: false
  gem "rubocop-performance"

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
  gem "listen", ">= 3.0.5", "< 3.11"
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
