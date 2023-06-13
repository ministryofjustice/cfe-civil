module RemarkGenerators
  class FrequencyChecker < BaseChecker
    include Exemptable

    def self.call(disposable_income_summary, collection, date_attribute = :payment_date)
      new(disposable_income_summary, collection).call(date_attribute) unless collection.empty?
    end

    def call(date_attribute = :payment_date)
      @date_attribute = date_attribute
      populate_remarks if unknown_frequency? && !exempt_from_checking
    end

  private

    def unknown_frequency?
      Utilities::PaymentPeriodAnalyser.new(dates).period_pattern == :unknown
    end

    def dates
      @collection.map { |rec| rec.send(@date_attribute) }
    end

    def populate_remarks
      RemarksData.new(type: record_type, issue: :unknown_frequency, ids: @collection.map(&:client_id))
    end
  end
end
