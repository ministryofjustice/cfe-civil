require "simplecov"
require "simplecov-lcov"
require "vcr"

# This allows both LCOV and HTML formatting -
# lcov for undercover gem and cc-test-reporter, HTML for humans
class SimpleCov::Formatter::MergedFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    SimpleCov::Formatter::LcovFormatter.new.format(result)
  end
end

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
# for cc-test-reporter after-build action
if ENV.key? "CI"
  SimpleCov::Formatter::LcovFormatter.config.output_directory = "coverage"
  SimpleCov::Formatter::LcovFormatter.config.lcov_file_name = "lcov.info"
end
SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

unless ENV["NOCOVERAGE"]
  SimpleCov.start do
    add_filter "spec/"
    add_filter "config/initializers/sentry.rb"
    add_filter "app/mailers/exception_alert_mailer.rb"
    add_filter "app/lib/exception_notifier/templated_notifier.rb"
    add_filter "app/services/request_rerunner.rb"
    add_filter "app/reports/assessment_stats.rb"

    enable_coverage :branch
    primary_coverage :branch
    minimum_coverage branch: 99.47, line: 100.0
  end
end

vcr_debug = ENV["VCR_DEBUG"].to_s == "true"
vcr_record_mode = ENV["VCR_RECORD_MODE"] ? ENV["VCR_RECORD_MODE"].to_sym : :once

VCR.configure do |vcr_config|
  vcr_config.cassette_library_dir = "spec/cassettes"
  vcr_config.hook_into :webmock
  vcr_config.default_cassette_options = {
    record: vcr_record_mode,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:key)],
  }
  vcr_config.ignore_hosts "www.googleapis.com"
  vcr_config.configure_rspec_metadata!
  vcr_config.debug_logger = $stdout if vcr_debug
  vcr_config.filter_sensitive_data("<GOOGLE_SHEETS_PRIVATE_KEY>") { ENV["GOOGLE_SHEETS_PRIVATE_KEY"] }
  vcr_config.filter_sensitive_data("<GOOGLE_SHEETS_PRIVATE_KEY_ID>") { ENV["GOOGLE_SHEETS_PRIVATE_KEY_ID"] }
end

# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.

  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  # NOTE: ENV['CI'] is a variable that is populated on circleci, at least, which
  # thereby prevents focused running in the CI pipeline.
  #
  # NOTE: you can also use `fit`, `fdescribe`, `fcontext` to focus specs
  #
  config.filter_run_including focus: true unless ENV["CI"]
  config.run_all_when_everything_filtered = true
  #
  #   # Allows RSpec to persist some state between runs in order to support
  #   # the `--only-failures` and `--next-failure` CLI options. We recommend
  #   # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "tmp/examples.txt"
  #
  #   # Limits the available syntax to the non-monkey patched syntax that is
  #   # recommended. For more details, see:
  #   #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  #   config.disable_monkey_patching!
  #
  #   # Many RSpec users commonly either run the entire suite or an individual
  #   # file, and it's useful to allow more verbose output when running an
  #   # individual spec file.
  #   if config.files_to_run.one?
  #     # Use the documentation formatter for detailed output,
  #     # unless a formatter has already been configured
  #     # (e.g. via a command-line flag).
  #     config.default_formatter = "doc"
  #   end
  #
  #   # Print the 10 slowest examples and example groups at the
  #   # end of the spec run, to help surface which specs are running
  #   # particularly slow.
  #   config.profile_examples = 10
  #
  #   # Run specs in random order to surface order dependencies. If you find an
  #   # order dependency and want to debug it, you can fix the order by providing
  #   # the seed, which is printed after each run.
  #   #     --seed 1234
  #   config.order = :random
  #
  #   # Seed global randomization in this process using the `--seed` CLI option.
  #   # Setting this allows you to use `--seed` to deterministically reproduce
  #   # test failures related to randomization by passing the same `--seed` value
  #   # as the one that triggered the failure.
  #   Kernel.srand config.seed
end
