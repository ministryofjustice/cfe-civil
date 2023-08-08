class RequestLog < RequestLogBase
  validates :request, :response, :user_agent, presence: true
  scope :with_client_reference, -> { where("request -> 'assessment' ->> 'client_reference_id' IS NOT NULL") }
end
