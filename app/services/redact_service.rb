# Redact client_ids. Only needed as a sweep-up after LEP-193, so delete after
# this has been run on both staging and production successfully (along with the test and rake task)
class RedactService
  class << self
    def call
      RequestLog.find_each do |li|
        li.update!(request: redact_data(li.request.deep_symbolize_keys), response: redact_response_data(li.response.deep_symbolize_keys))
      end
    end

    def redact_old_client_refs
      RequestLog.with_client_reference.where("created_at < ?", 14.days.ago.to_date).find_each do |li|
        li.update!(request: redact_client_ref(li.request.deep_symbolize_keys))
      end
    end

    def redact_time(timestamp)
      Date.parse(timestamp).strftime("%Y-%m-%d")
    end

    def redact_dob(submission_date, date_of_birth)
      now = safe_parse_date submission_date
      dob = safe_parse_date date_of_birth
      if now.present? && dob.present?
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

    def updated_remarks(remarks)
      remarks.map { |key, value|
        if Remarks::VALID_REMARK_TYPES.any?(key.to_sym) && (value.is_a? Hash)
          value = redact_remarks_client_ids(value)
        end
        [key, value]
      }.to_h
    end

  private

    def safe_parse_date(date)
      Date.parse(date) if date
    rescue ArgumentError
      nil
    end

    def redact_client_ref(request)
      request.tap do |req|
        req[:assessment][:client_reference_id] = CFEConstants::REDACTED_MESSAGE
      end
    end

    def redact_data(hash)
      submission_date = hash.dig(:assessment, :submission_date)
      filter_payload(submission_date, hash)
    end

    def filter_payload(submission_date, hash)
      hash.each do |key, value|
        if key == :client_id
          hash[key] = CFEConstants::REDACTED_MESSAGE
        elsif key == :date_of_birth
          hash[key] = redact_dob(submission_date, hash[key])
        elsif value.is_a?(Hash)
          filter_payload(submission_date, value)
        elsif value.is_a?(Array)
          value.select { |v| v.is_a?(Hash) }.each { |item| filter_payload(submission_date, item) }
        end
      end
    end

    def redact_response_data(hash)
      hash[:timestamp] = redact_time(hash[:timestamp]) if hash.key? :timestamp
      assessment = hash[:assessment]
      assessment[:remarks] = updated_remarks(assessment[:remarks]) if assessment&.key? :remarks
      hash
    end

    def redact_remarks_client_ids(object)
      object.transform_values do |value|
        case value
        when Hash
          redact_remarks_client_ids(value)
        when Array
          value.map { |_client_id| CFEConstants::REDACTED_MESSAGE }
        else
          CFEConstants::REDACTED_MESSAGE
        end
      end
    end
  end
end
