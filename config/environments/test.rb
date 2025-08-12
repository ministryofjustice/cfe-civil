# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.after_initialize do
    Bullet.enable        = true
    Bullet.bullet_logger = true
    # Some tests don't use all the possible eager loading depending on what they are doing
    Bullet.unused_eager_loading_enable = false
    Bullet.raise = true # raise an error if n+1 query occurs
  end

  # Configure 'rails notes' to inspect Cucumber files
  config.annotations.register_directories("features")
  config.annotations.register_extensions("feature") { |tag| /#\s*(#{tag}):?\s*(.*)$/ }

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports.
  config.consider_all_requests_local = true
  config.cache_store = :memory_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  # config.action_mailer.delivery_method = :test

  # Set host to be used by links generated in mailer templates.
  # config.action_mailer.default_url_options = { host: "example.com" }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Raise error when a before_action's only/except options reference missing actions
  # config.action_controller.raise_on_missing_callback_actions = true
  config.x.use_test_threshold_data = "true"

  config.x.legal_framework_api_host = "https://legal-framework-api-staging.cloud-platform.service.justice.gov.uk"
end
