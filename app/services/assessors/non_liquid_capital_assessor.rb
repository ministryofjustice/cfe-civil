module Assessors
  class NonLiquidCapitalAssessor
    class << self
      def call(non_liquid_capital_items)
        non_liquid_capital_items.sum(&:value).round(2)
      end
    end
  end
end
