require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require_relative "../app/services/remarks"

module CheckFinancialEligibility
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Changes in rails 7.0.3.1 prevented Symbols being used in serialised fields
    # this overrides the setting and allows the code(and tests) to run as normal
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Remarks]

    config.x.status.build_date = ENV["BUILD_DATE"] || "Not Available"
    config.x.status.build_tag = ENV["BUILD_TAG"] || "Not Available"
    config.x.status.app_branch = ENV["APP_BRANCH"] || "Not Available"
    config.x.use_test_threshold_data = ENV["USE_TEST_THRESHOLD_DATA"]
    config.autoload_paths += %W[#{config.root}/app/validators]

    config.x.legal_framework_api_host = ENV["LEGAL_FRAMEWORK_API_HOST"]
  end
end

require "rswag_ui_csp"
