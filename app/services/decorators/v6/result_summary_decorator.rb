module Decorators
  module V6
    class ResultSummaryDecorator
      attr_reader :assessment

      def initialize(assessment, calculation_output)
        @assessment = assessment
        @calculation_output = calculation_output
      end

      def as_json
        details = {
          overall_result: {
            result: @assessment.assessment_result,
            capital_contribution: @calculation_output.capital_subtotals.capital_contribution.to_f,
            income_contribution: assessment.applicant_disposable_income_summary.income_contribution.to_f,
            proceeding_types: ProceedingTypesResultDecorator.new(assessment.eligibilities, assessment.proceeding_types).as_json,
          },
          gross_income: GrossIncomeResultDecorator.new(assessment.applicant_gross_income_summary,
                                                       @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals,
                                                       @calculation_output.gross_income_subtotals.combined_monthly_gross_income.to_f),
          disposable_income: DisposableIncomeResultDecorator.new(
            assessment.applicant_disposable_income_summary,
            assessment.applicant_gross_income_summary,
            @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals,
            partner_present: assessment.partner.present?,
            disposable_income_subtotals: @calculation_output.applicant_disposable_income_subtotals,
          ),
          capital: ApplicantCapitalResultDecorator.new(
            summary: assessment.applicant_capital_summary,
            applicant_capital_subtotals: @calculation_output.capital_subtotals.applicant_capital_subtotals,
            partner_capital_subtotals: @calculation_output.capital_subtotals.partner_capital_subtotals,
            capital_contribution: @calculation_output.capital_subtotals.capital_contribution.to_f,
            combined_assessed_capital: @calculation_output.capital_subtotals.combined_assessed_capital.to_f,
          ),
        }
        result = if assessment.partner
                   details.merge(partner_capital:, partner_gross_income:, partner_disposable_income:)
                 else
                   details
                 end
        result.transform_values(&:as_json)
      end

      def partner_gross_income
        GrossIncomeResultDecorator.new(assessment.partner_gross_income_summary,
                                       @calculation_output.gross_income_subtotals.partner_gross_income_subtotals,
                                       @calculation_output.gross_income_subtotals.combined_monthly_gross_income.to_f)
      end

      def partner_disposable_income
        DisposableIncomeResultDecorator.new(
          assessment.partner_disposable_income_summary,
          assessment.partner_gross_income_summary,
          @calculation_output.gross_income_subtotals.partner_gross_income_subtotals.employment_income_subtotals,
          partner_present: true,
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
