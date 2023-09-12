module Decorators
  module V6
    class ResultSummaryDecorator
      attr_reader :assessment

      def initialize(assessment, calculation_output, partner_present)
        @assessment = assessment
        @calculation_output = calculation_output
        @partner_present = partner_present
      end

      def as_json
        details = {
          overall_result: {
            result: @assessment.assessment_result,
            capital_contribution: @calculation_output.capital_subtotals.capital_contribution.to_f,
            income_contribution: @calculation_output.income_contribution.to_f,
            proceeding_types: ProceedingTypesResultDecorator.new(assessment.eligibilities, assessment.proceeding_types).as_json,
          },
          gross_income: ApplicantGrossIncomeResultDecorator.new(summary: assessment.applicant_gross_income_summary,
                                                                person_gross_income_subtotals: @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals,
                                                                combined_monthly_gross_income: @calculation_output.gross_income_subtotals.combined_monthly_gross_income),
          disposable_income: ApplicantDisposableIncomeResultDecorator.new(
            assessment.applicant_disposable_income_summary,
            assessment.applicant_gross_income_summary,
            @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals,
            disposable_income_subtotals: @calculation_output.applicant_disposable_income_subtotals,
            combined_total_disposable_income: @calculation_output.combined_total_disposable_income,
            combined_total_outgoings_and_allowances: @calculation_output.combined_total_outgoings_and_allowances,
            income_contribution: @calculation_output.income_contribution,
          ),
          capital: ApplicantCapitalResultDecorator.new(
            summary: assessment.applicant_capital_summary,
            applicant_capital_subtotals: @calculation_output.capital_subtotals.applicant_capital_subtotals,
            partner_capital_subtotals: @calculation_output.capital_subtotals.partner_capital_subtotals,
            capital_contribution: @calculation_output.capital_subtotals.capital_contribution.to_f,
            combined_assessed_capital: @calculation_output.capital_subtotals.combined_assessed_capital.to_f,
          ),
        }
        result = if @partner_present
                   details.merge(partner_capital:, partner_gross_income:, partner_disposable_income:)
                 else
                   details
                 end
        result.transform_values(&:as_json)
      end

      def partner_gross_income
        GrossIncomeResultDecorator.new(@calculation_output.gross_income_subtotals.partner_gross_income_subtotals)
      end

      def partner_disposable_income
        DisposableIncomeResultDecorator.new(
          assessment.partner_disposable_income_summary,
          assessment.partner_gross_income_summary,
          @calculation_output.gross_income_subtotals.partner_gross_income_subtotals.employment_income_subtotals,
          disposable_income_subtotals: @calculation_output.partner_disposable_income_subtotals,
        )
      end

      def partner_capital
        CapitalResultDecorator.new(assessment.partner_capital_summary,
                                   @calculation_output.capital_subtotals.partner_capital_subtotals)
      end
    end
  end
end
