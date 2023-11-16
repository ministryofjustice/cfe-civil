module RemarkGenerators
  class FrequencyChecker < BaseChecker
    def self.call(child_care_bank:, collection:, date_attribute: :payment_date)
      new(child_care_bank:, collection:).call(date_attribute) unless collection.empty?
    end

    def initialize(child_care_bank:, collection:)
      super(collection)
      @child_care_bank = child_care_bank
    end

    def call(date_attribute = :payment_date)
      @date_attribute = date_attribute
      populate_remarks if unknown_frequency? && !exempt_from_checking?
    end

  private

    def exempt_from_checking?
      Utilities::ChildcareExemptionDetector.call(record_type, @child_care_bank)
    end

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
