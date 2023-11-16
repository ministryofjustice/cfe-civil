module RemarkGenerators
  class FrequencyChecker < BaseChecker
    class << self
      def call(child_care_bank:, collection:, date_attribute: :payment_date)
        check(child_care_bank:, collection:, date_attribute:) unless collection.empty?
      end

    private

      def check(child_care_bank:, collection:, date_attribute:)
        populate_remarks(collection) if unknown_frequency?(collection:, date_attribute:) && !exempt_from_checking?(child_care_bank:, collection:)
      end

      def exempt_from_checking?(child_care_bank:, collection:)
        Utilities::ChildcareExemptionDetector.call(record_type(collection), child_care_bank)
      end

      def unknown_frequency?(collection:, date_attribute:)
        Utilities::PaymentPeriodAnalyser.new(dates(collection:, date_attribute:)).period_pattern == :unknown
      end

      def dates(collection:, date_attribute:)
        collection.map { |rec| rec.send(date_attribute) }
      end

      def populate_remarks(collection)
        RemarksData.new(type: record_type(collection), issue: :unknown_frequency, ids: collection.map(&:client_id))
      end
    end
  end
end
