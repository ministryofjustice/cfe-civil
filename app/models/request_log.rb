class RequestLog < RequestLogRecord
  validates :request, :response, :user_agent, presence: true
end
