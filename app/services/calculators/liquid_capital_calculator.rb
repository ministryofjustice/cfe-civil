module Calculators
  class LiquidCapitalCalculator
    class << self
      def call(liquid_capital_items)
        liquid_capital_items.map { CapitalItemCalculator::CapitalData.new(capital_item: _1, result: result(_1)) }
      end

    private

      def result(item)
        if item.value.positive?
          CapitalItemCalculator::Result.new(value: item.value)
        else
          CapitalItemCalculator::Result.new(value: 0)
        end
      end
    end
  end
end
