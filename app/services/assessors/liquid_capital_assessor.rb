module Assessors
  class LiquidCapitalAssessor
    class << self
      def call(liquid_capital_items)
        liquid_capital_items.select { _1.value.positive? }.sum(&:value)
      end
    end
  end
end
