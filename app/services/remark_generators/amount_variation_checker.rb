module RemarkGenerators
  class AmountVariationChecker < BaseChecker
    include Exemptable

    def call
      populate_remarks unless unique_amounts || exempt_from_checking
    end

  private

    def unique_amounts
      @collection.map(&:amount).uniq.size == 1
    end

    def populate_remarks
      RemarksData.new(record_type, :amount_variation, @collection.map(&:client_id))
    end
  end
end
