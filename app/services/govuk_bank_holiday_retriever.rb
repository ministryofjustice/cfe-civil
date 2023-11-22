class GovukBankHolidayRetriever
  def self.dates
    new.dates(CFEConstants::GOVUK_BANK_HOLIDAY_DEFAULT_GROUP)
  end

  def dates(group)
    JSON.parse(response.body).dig(group, "events")&.pluck("date")
  end

private

  def response
    # The Faraday::HttpCache middleware is slightly 'broken' as it doesn't respect the TTL of the
    # response, and relies on the expiry time set on the 'store' object passed to
    # it. k8s pods get recycled regularly anyway, so the expiry time is unlikely
    # to be exceeded
    store = ActiveSupport::Cache.lookup_store(:file_store, "tmp/cache", expires_in: 10.days)
    client = Faraday.new do |builder|
      builder.use Faraday::HttpCache, store:, strategy: Faraday::HttpCache::Strategies::ByUrl, logger: Rails.logger
      builder.adapter Faraday.default_adapter
      builder.response :raise_error
    end

    @response ||= client.get(uri)
  end

  def uri
    URI.parse(CFEConstants::GOVUK_BANK_HOLIDAY_API_URL)
  end
end
