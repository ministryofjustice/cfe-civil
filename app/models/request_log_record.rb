class RequestLogRecord < ApplicationRecord
  self.abstract_class = true

  # if we're reading request logs, they could be coming from a remote source
  connects_to database: { writing: :primary, reading: :request_log }
end
