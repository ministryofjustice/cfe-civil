class GovukBankHolidayRetriever
  def self.dates
    new.dates(CFEConstants::GOVUK_BANK_HOLIDAY_DEFAULT_GROUP)
  end

  def dates(group)
    JSON.parse(response.body).dig(group, "events")&.pluck("date")
  end

private

  def response
    store = Rails.cache
    # store = ActiveSupport::Cache.lookup_store(:file_store, "/tmp/cache", expires_in: 5.seconds)
    client = Faraday.new do |builder|
      builder.use Faraday::HttpCache, store:, strategy: Faraday::HttpCache::Strategies::ByUrl, logger: Rails.logger
      builder.adapter Faraday.default_adapter
      builder.response :raise_error
      # builder.response :json, parser_options: { symbolize_names: false }

      # builder.response :logger, Rails.logger, headers: true, bodies: false, log_level: :debug
    end

    @response ||= client.get(uri)
  end

  def uri
    URI.parse(CFEConstants::GOVUK_BANK_HOLIDAY_API_URL)
  end
end
