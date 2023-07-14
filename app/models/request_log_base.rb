# rubocop:disable Rails/UnknownEnv
# :nocov:
class RequestLogBase < ApplicationRecord
  self.abstract_class = true

  # if we're reading request logs, they could be coming from a remote source
  if Rails.env.remote_database?
    connects_to database: { writing: :primary, reading: :request_log }
  end
end
# :nocov:
# rubocop:enable Rails/UnknownEnv
