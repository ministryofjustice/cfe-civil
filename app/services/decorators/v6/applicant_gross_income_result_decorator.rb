module Decorators
  module V6
    class ApplicantGrossIncomeResultDecorator < GrossIncomeResultDecorator
      def initialize(total_gross_income:, eligibilities:, combined_monthly_gross_income:)
        super(total_gross_income)
        @combined_monthly_gross_income = combined_monthly_gross_income
        @eligibilities = eligibilities
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
