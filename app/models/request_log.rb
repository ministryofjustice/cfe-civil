class RequestLog < ApplicationRecord
  def self.create_from_request(request)
    create!(request: request.params.except(:controller, :action))
  end

  def update_from_response(response, duration)
    update!(http_status: response.status,
            response: JSON.parse(response.body),
            duration:)
  end
end
