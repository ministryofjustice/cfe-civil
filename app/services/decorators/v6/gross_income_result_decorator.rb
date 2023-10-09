module Decorators
  module V6
    class GrossIncomeResultDecorator
      def initialize(person_gross_income_subtotals)
        @person_gross_income_subtotals = person_gross_income_subtotals
      end

      def as_json
        {
          total_gross_income: @person_gross_income_subtotals.total_gross_income.to_f,
        }
      end
    end
  end
end
