# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]

# redact client_id's
Rails.application.config.filter_parameters << lambda do |key, value|
  value.gsub!(value, CFEConstants::REDACTED_MESSAGE) if /client_id/.match?(key)
end
