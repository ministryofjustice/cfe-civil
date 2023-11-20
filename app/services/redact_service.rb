# Redact client_ids. Only needed as a sweep-up after LEP-193, so delete after
# this has been run on both staging and production successfully (along with the test and rake task)
class RedactService
  class << self
    def call
      RequestLog.find_each do |li|
        li.update!(request: redact_request(li.request.deep_symbolize_keys), response: redact_response(li.response.deep_symbolize_keys))
      end
    end

    def redact_response(response_hash)
      response_hash[:timestamp] = redact_time(response_hash[:timestamp]) if response_hash.key? :timestamp
      assessment = response_hash[:assessment]
      if assessment.present?
        assessment[:remarks] = redact_remarks(assessment[:remarks])
        applicant = assessment.fetch(:applicant, {})
        applicant[:date_of_birth] = redact_dob(assessment[:submission_date], applicant[:date_of_birth])
      end

      response_hash
    end

    def redact_old_client_refs
      RequestLog.with_client_reference.created_before(14.days.ago.to_date).find_each do |li|
        li.update!(request: redact_client_ref(li.request.deep_symbolize_keys))
      end
    end

    def redact_dob(submission_date, date_of_birth)
      now = safe_parse_date submission_date
      dob = safe_parse_date date_of_birth
      # don't redact if we're on the person's birthday as there is nothing to do
      if now.present? && dob.present? && (now.month != dob.month || now.day != dob.day)
        redacted = Date.new(dob.year, now.month, now.day)
        if redacted > dob
          (redacted - 1.year + 1.day).to_s
        else
          (redacted + 1.day).to_s
        end
      else
        date_of_birth
      end
    end

    def redact_remarks(remarks)
      remarks.map { |type, issues|
        if issues.is_a? Hash
          issues.transform_values! { |ids|
            ids.map { |_client_id| CFEConstants::REDACTED_MESSAGE }
          }.to_h
        end
        [type, issues]
      }.to_h
    end

    def redact_time(timestamp)
      Date.parse(timestamp).strftime("%Y-%m-%d")
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

    def redact_request(hash)
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
  end
end
