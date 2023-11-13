module Calculators
  class NonLiquidCapitalCalculator
    class << self
      def call(non_liquid_capital_items)
        non_liquid_capital_items.map { CapitalItemCalculator::CapitalData.new(capital_item: _1, result: result(_1)) }
      end

    private

      def result(item)
        CapitalItemCalculator::Result.new(value: item.value)
      end
    end
  end
end
