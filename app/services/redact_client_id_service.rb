# Redact client_ids. Only needed as a sweep-up after LEP-193, so delete after
# this has been run on both staging and production successfully (along with the test and rake task)
class RedactClientIdService
  class << self
    def call
      RequestLog.find_each do |li|
        li.update!(request: filter_client_ids(li.request.deep_symbolize_keys))
      end
    end

  private

    def filter_client_ids(hash)
      hash.each do |key, value|
        if key == :client_id
          hash[key] = CFEConstants::REDACTED_MESSAGE
        elsif value.is_a?(Hash)
          filter_client_ids(value)
        elsif value.is_a?(Array)
          value.select { |v| v.is_a?(Hash) }.each { |item| filter_client_ids(item) }
        end
      end
    end
  end
end
