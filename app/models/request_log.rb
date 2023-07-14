class RequestLog < RequestLogBase
  validates :request, :response, :user_agent, presence: true
end
