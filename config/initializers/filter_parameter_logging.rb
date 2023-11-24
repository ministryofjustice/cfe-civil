# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += %i[
  passw secret token _key crypt salt certificate otp ssn
]

# redact client_id's
Rails.application.config.filter_parameters << lambda do |key, value|
  value.gsub!(value, CFEConstants::REDACTED_MESSAGE) if /client_id/.match?(key)
end
