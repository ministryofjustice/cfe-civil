# Redact client_ids. Only needed as a sweep-up after LEP-193, so delete after
# this has been run on both staging and production successfully (along with the test and rake task)
class RedactService
  class << self
    def call
      RequestLog.find_each do |li|
        li.update!(request: redact_data(li.request.deep_symbolize_keys))
      end
    end

  private

    def redact_data(hash)
      submission_date = hash.dig(:assessment, :submission_date)
      filter_client_ids(submission_date, hash)
    end

    def filter_client_ids(submission_date, hash)
      hash.each do |key, value|
        if key == :client_id
          hash[key] = CFEConstants::REDACTED_MESSAGE
        elsif key == :date_of_birth
          hash[key] = RequestLogger.redact_dob(submission_date, hash[key])
        elsif value.is_a?(Hash)
          filter_client_ids(submission_date, value)
        elsif value.is_a?(Array)
          value.select { |v| v.is_a?(Hash) }.each { |item| filter_client_ids(submission_date, item) }
        end
      end
    end
  end
end
