module RemarkGenerators
  class AmountVariationChecker < BaseChecker
    def self.call(collection:, child_care_bank:)
      new(child_care_bank:, collection:).call
    end

    def initialize(child_care_bank:, collection:)
      super(collection)
      @child_care_bank = child_care_bank
    end

    def call
      populate_remarks unless unique_amounts || exempt_from_checking?
    end

  private

    def exempt_from_checking?
      Utilities::ChildcareExemptionDetector.call(record_type, @child_care_bank)
    end

    def unique_amounts
      @collection.map(&:amount).uniq.size == 1
    end

    def populate_remarks
      RemarksData.new(record_type, :amount_variation, @collection.map(&:client_id))
    end
  end
end
