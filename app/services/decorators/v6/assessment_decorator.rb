module Decorators
  module V6
    class AssessmentDecorator
      attr_reader :assessment

      def initialize(assessment, calculation_output)
        @assessment = assessment
        @calculation_output = calculation_output
      end

      def as_json
        {
          version: assessment.version,
          timestamp: Time.current,
          success: true,
          result_summary: ResultSummaryDecorator.new(assessment, @calculation_output).as_json,
          assessment: assessment_details.transform_values(&:as_json),
        }
      end

    private

      def assessment_details
        details = {
          id: assessment.id,
          client_reference_id: assessment.client_reference_id,
          submission_date: assessment.submission_date,
          level_of_help: assessment.level_of_help,
          applicant: ApplicantDecorator.new(assessment.applicant),
          gross_income:,
          disposable_income: DisposableIncomeDecorator.new(
            summary: assessment.applicant_disposable_income_summary,
            disposable_income_subtotals: @calculation_output.applicant_disposable_income_subtotals,
            state_benefits: @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.state_benefits,
          ),
          capital: CapitalDecorator.new(assessment.applicant_capital_summary,
                                        @calculation_output.capital_subtotals.applicant_capital_subtotals),
          remarks: RemarksDecorator.new(assessment.remarks, assessment),
        }
        if assessment.partner
          details.merge(partner_gross_income:, partner_disposable_income:, partner_capital:)
        else
          details
        end
      end

      def gross_income
        GrossIncomeDecorator.new(assessment.applicant_gross_income_summary,
                                 assessment.employments,
                                 @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals,
                                 @calculation_output.gross_income_subtotals.self_employments)
      end

      def partner_gross_income
        GrossIncomeDecorator.new(assessment.partner_gross_income_summary,
                                 assessment.partner_employments,
                                 @calculation_output.gross_income_subtotals.partner_gross_income_subtotals,
                                 @calculation_output.gross_income_subtotals.partner_self_employments)
      end

      def partner_disposable_income
        DisposableIncomeDecorator.new(summary: assessment.partner_disposable_income_summary,
                                      disposable_income_subtotals: @calculation_output.partner_disposable_income_subtotals,
                                      state_benefits: @calculation_output.gross_income_subtotals.partner_gross_income_subtotals.state_benefits)
      end

      def partner_capital
        CapitalDecorator.new(assessment.partner_capital_summary,
                             @calculation_output.capital_subtotals.partner_capital_subtotals)
      end
    end
  end
end
