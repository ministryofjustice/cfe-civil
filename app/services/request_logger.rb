class RequestLogger
  class << self
    def log_request(duration, payload)
      event_params = payload.fetch(:params).except("controller", "action")
      now = event_params.dig(:assessment, :submission_date)

      applicant_params = event_params[:applicant]
      applicant_params[:date_of_birth] = redact_dob(now, applicant_params[:date_of_birth]) if applicant_params

      partner_params = event_params[:partner]
      if partner_params
        partner = partner_params[:partner]
        partner[:date_of_birth] = redact_dob(now, partner[:date_of_birth]) if partner
        partner_params.fetch(:dependants, []).each do |d|
          d[:date_of_birth] = redact_dob(now, d[:date_of_birth])
        end
      end

      event_params.fetch(:dependants, []).each do |d|
        d[:date_of_birth] = redact_dob(now, d[:date_of_birth])
      end

      response = JSON.parse(payload.fetch(:response).body)
      if response.key?("timestamp")
        response["timestamp"] = redact_time(response["timestamp"])
      end

      assessment = response["assessment"]
      if assessment && assessment["remarks"]
        assessment["remarks"] = redact_remarks_client_ids(assessment["remarks"])
      end

      RequestLog.create!(
        request: event_params,
        http_status: payload.fetch(:status),
        response:,
        duration:,
        user_agent: payload.fetch(:headers).fetch("HTTP_USER_AGENT", "unknown"),
      )
    end

    def redact_remarks_client_ids(object)
      object.transform_values do |value|
        case value
        when Hash
          redact_remarks_client_ids(value)
        when Array
          value.map { |_client_id| CFEConstants::REDACTED_MESSAGE }
        end
      end
    end

    def redact_time(timestamp)
      Date.parse(timestamp).strftime("%Y-%m-%d")
    end

    def redact_dob(submission_date, date_of_birth)
      if submission_date.present? && date_of_birth.present?
        now = Date.parse(submission_date)
        dob = Date.parse date_of_birth
        redacted = Date.new dob.year, now.month, now.day
        if redacted > dob
          Date.new(redacted.year - 1, redacted.month, redacted.day).to_s
        else
          redacted.to_s
        end
      else
        date_of_birth
      end
    end
  end
end
