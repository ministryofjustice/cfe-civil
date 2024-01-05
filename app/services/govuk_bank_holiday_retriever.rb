class GovukBankHolidayRetriever
  # Date and bank holidays
  #
  GOVUK_BANK_HOLIDAY_API_URL = "https://www.gov.uk/bank-holidays.json".freeze
  GOVUK_BANK_HOLIDAY_DEFAULT_GROUP = "england-and-wales".freeze

  class << self
    def dates
      JSON.parse(response_body).dig(GOVUK_BANK_HOLIDAY_DEFAULT_GROUP, "events").pluck("date")
    end

  private

    def response_body
      client = Faraday.new do |builder|
        builder.adapter Faraday.default_adapter
        builder.response :raise_error
      end

      Rails.cache.fetch(uri, expires_in: 10.days) do
        client.get(uri).body
      end
    end

    def uri
      URI.parse(GOVUK_BANK_HOLIDAY_API_URL)
    end
  end
end
