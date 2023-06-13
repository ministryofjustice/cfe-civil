module Assessors
  class NonLiquidCapitalAssessor
    class << self
      def call(non_liquid_capital_items)
        non_liquid_capital_items.map { CapitalItemAssessor::CapitalData.new(capital_item: _1, result: result(_1)) }
      end

    private

      def result(item)
        CapitalItemAssessor::Result.new(value: item.value)
      end
    end
  end
end
