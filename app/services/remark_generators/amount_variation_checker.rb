module RemarkGenerators
  class AmountVariationChecker < BaseChecker
    class << self
      def call(collection:, child_care_bank:)
        populate_remarks(collection) unless unique_amounts(collection) || exempt_from_checking?(collection:, child_care_bank:)
      end

    private

      def exempt_from_checking?(collection:, child_care_bank:)
        Utilities::ChildcareExemptionDetector.call(record_type(collection), child_care_bank)
      end

      def unique_amounts(collection)
        collection.map(&:amount).uniq.size == 1
      end

      def populate_remarks(collection)
        RemarksData.new(record_type(collection), :amount_variation, collection.map(&:client_id))
      end
    end
  end
end
