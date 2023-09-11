module Decorators
  module V6
    class ApplicantGrossIncomeResultDecorator < GrossIncomeResultDecorator
      def initialize(proceeding_type_results:, person_gross_income_subtotals:, combined_monthly_gross_income:)
        super(person_gross_income_subtotals)
        @proceeding_type_results = proceeding_type_results
        @combined_monthly_gross_income = combined_monthly_gross_income
      end

      def as_json
        super.merge(proceeding_types:, combined_total_gross_income: @combined_monthly_gross_income)
      end

    private

      def proceeding_types
        ProceedingTypesResultDecorator.new(@proceeding_type_results).as_json
      end
    end
  end
end
