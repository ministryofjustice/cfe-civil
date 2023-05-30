class RequestLog < ApplicationRecord
  validates :request, :response, :user_agent, presence: true
end
