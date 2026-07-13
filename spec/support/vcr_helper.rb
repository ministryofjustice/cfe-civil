require "vcr"

vcr_debug = ENV["VCR_DEBUG"].to_s == "true"
vcr_record_mode = ENV["VCR_RECORD_MODE"] ? ENV["VCR_RECORD_MODE"].to_sym : :once

VCR.configure do |vcr_config|
  vcr_config.cassette_library_dir = "spec/cassettes"
  vcr_config.hook_into :webmock

  vcr_config.default_cassette_options = {
    record: vcr_record_mode,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:key)],
  }

  # ignore requests config
  vcr_config.ignore_hosts "www.googleapis.com"
  vcr_config.ignore_request do |_request|
    RSpec.current_example&.metadata&.fetch(:pact, false) # ignore pact test requests to its own mock server
  end

  vcr_config.configure_rspec_metadata!
  vcr_config.debug_logger = $stdout if vcr_debug
  vcr_config.filter_sensitive_data("<GOOGLE_SHEETS_PRIVATE_KEY>") { ENV.fetch("GOOGLE_SHEETS_PRIVATE_KEY", "GOOGLE_SHEETS_PRIVATE_KEY") }
  vcr_config.filter_sensitive_data("<GOOGLE_SHEETS_PRIVATE_KEY_ID>") { ENV.fetch("GOOGLE_SHEETS_PRIVATE_KEY_ID", "GOOGLE_SHEETS_PRIVATE_KEY_ID") }
end
