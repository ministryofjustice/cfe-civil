# frozen_string_literal: true

class GovukBankHolidayRetriever
  UnsuccessfulRetrievalError = Class.new(StandardError)

  def self.dates
    new.dates(CFEConstants::GOVUK_BANK_HOLIDAY_DEFAULT_GROUP)
  end

  def data
    return raise_error unless response.status == 200

    @data ||= JSON.parse(response.body)
  end

  def dates(group)
    return if data.empty?

    data.dig(group, "events")&.pluck("date")
  end

private

  def response
    client = Faraday.new do |builder|
      builder.use Faraday::HttpCache, store: Rails.cache
      builder.adapter Faraday.default_adapter
      builder.response :logger, Rails.logger, headers: true, bodies: true, log_level: :debug
    end

    @response ||= client.get(uri)
  end

  def uri
    URI.parse(CFEConstants::GOVUK_BANK_HOLIDAY_API_URL)
  end

  def raise_error
    raise UnsuccessfulRetrievalError, "Retrieval Failed: #{response.message} (#{response.code}) #{response.body}"
  end
end
