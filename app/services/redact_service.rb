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
      RequestLog.find_each.select { |log| log.created_at < 14.days.ago }.each do |li|
        li.update!(request: redact_client_ref(li.request.deep_symbolize_keys))
      end
    end

  private

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
          hash[key] = RequestLogger.redact_dob(submission_date, hash[key])
        elsif value.is_a?(Hash)
          filter_payload(submission_date, value)
        elsif value.is_a?(Array)
          value.select { |v| v.is_a?(Hash) }.each { |item| filter_payload(submission_date, item) }
        end
      end
    end

    def redact_response_data(hash)
      hash[:timestamp] = RequestLogger.redact_time(hash[:timestamp]) if hash.key? :timestamp
      assessment = hash[:assessment]
      assessment[:remarks] = RequestLogger.updated_remarks(assessment[:remarks]) if assessment&.key? :remarks
      hash
    end
  end
end
