module Decorators
  module V6
    class GrossIncomeResultDecorator
      def initialize(total_gross_income)
        @total_gross_income = total_gross_income
      end

      def as_json
        {
          total_gross_income: @total_gross_income.to_f,
        }
      end
    end
  end
end
