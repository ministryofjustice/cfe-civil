class RequestLogger
  class << self
    def log_request(duration, payload)
      event_params = payload.fetch(:params).except("controller", "action")
      now = event_params.dig(:assessment, :submission_date)

      applicant_params = event_params[:applicant]
      applicant_params[:date_of_birth] = RedactService.redact_dob(now, applicant_params[:date_of_birth]) if applicant_params

      partner_params = event_params[:partner]
      if partner_params
        partner = partner_params[:partner]
        partner[:date_of_birth] = RedactService.redact_dob(now, partner[:date_of_birth]) if partner
        partner_params.fetch(:dependants, []).each do |d|
          d[:date_of_birth] = RedactService.redact_dob(now, d[:date_of_birth])
        end
      end

      event_params.fetch(:dependants, []).each do |d|
        d[:date_of_birth] = RedactService.redact_dob(now, d[:date_of_birth])
      end

      response = JSON.parse(payload.fetch(:response).body)
      if response.key?("timestamp")
        response["timestamp"] = RedactService.redact_time(response["timestamp"])
      end

      assessment = response["assessment"]
      if assessment && assessment["remarks"]
        assessment["remarks"] = RedactService.updated_remarks(assessment["remarks"])
      end

      response = JSON.parse(payload.fetch(:response).body).deep_symbolize_keys
      RequestLog.create!(
        request: event_params,
        http_status: payload.fetch(:status),
        response: RedactService.redact_response(response),
        duration:,
        user_agent: payload.fetch(:headers).fetch("HTTP_USER_AGENT", "unknown"),
      )
    end
  end
end
