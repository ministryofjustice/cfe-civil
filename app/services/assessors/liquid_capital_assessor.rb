module Assessors
  class LiquidCapitalAssessor
    class << self
      def call(liquid_capital_items)
        liquid_capital_items.map { CapitalItemAssessor::CapitalData.new(capital_item: _1, result: result(_1)) }
      end

    private

      def result(item)
        if item.value.positive?
          CapitalItemAssessor::Result.new(value: item.value)
        else
          CapitalItemAssessor::Result.new(value: 0)
        end
      end
    end
  end
end
