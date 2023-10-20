module Decorators
  module V6
    class ApplicantGrossIncomeResultDecorator < GrossIncomeResultDecorator
      def initialize(gross_income_subtotals:, proceeding_types:)
        super(gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income)
        @eligibilities = gross_income_subtotals.eligibilities(proceeding_types)
        @combined_monthly_gross_income = gross_income_subtotals.combined_monthly_gross_income
      end

      def as_json
        super.merge(proceeding_types:, combined_total_gross_income: @combined_monthly_gross_income)
      end

    private

      def proceeding_types
        ProceedingTypesResultDecorator.new(@eligibilities).as_json
      end
    end
  end
end
