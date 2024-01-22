module Decorators
  module V6
    class AssessmentDecorator
      attr_reader :assessment

      def initialize(assessment:, calculation_output:, applicant:, partner:, version:, eligibility_result:, remarks:, proceeding_types:, explicit_remarks:)
        @assessment = assessment
        @calculation_output = calculation_output
        @applicant = applicant
        @partner = partner
        @version = version
        @eligibility_result = eligibility_result
        @remarks = remarks
        @proceeding_types = proceeding_types
        @explicit_remarks = explicit_remarks
      end

      def as_json
        {
          version: @version,
          timestamp: Time.current,
          success: true,
          result_summary: result_summary_decorator_class.new(assessment:, calculation_output: @calculation_output,
                                                             eligibility_result: @eligibility_result,
                                                             proceeding_types: @proceeding_types,
                                                             partner_present: @partner.present?).as_json,
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
          applicant: applicant_decorator_class.new(@applicant.details),
          gross_income:,
          disposable_income: DisposableIncomeDecorator.new(
            disposable_income_subtotals: @calculation_output.applicant_disposable_income_subtotals,
            state_benefits: @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.state_benefits,
          ),
          capital: CapitalDecorator.new(@calculation_output.capital_subtotals.applicant_capital_subtotals),
          remarks: RemarksDecorator.new(@explicit_remarks, @remarks, @eligibility_result.summarized_assessment_result),
        }
        if @partner.present?
          details.merge(partner_gross_income:, partner_disposable_income:, partner_capital:)
        else
          details
        end
      end

      def applicant_decorator_class
        ApplicantDecorator
      end

      def result_summary_decorator_class
        ResultSummaryDecorator
      end

      def gross_income
        GrossIncomeDecorator.new(@applicant.employments,
                                 @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals)
      end

      def partner_gross_income
        GrossIncomeDecorator.new(@partner.employments,
                                 @calculation_output.gross_income_subtotals.partner_gross_income_subtotals)
      end

      def partner_disposable_income
        DisposableIncomeDecorator.new(disposable_income_subtotals: @calculation_output.partner_disposable_income_subtotals,
                                      state_benefits: @calculation_output.gross_income_subtotals.partner_gross_income_subtotals.state_benefits)
      end

      def partner_capital
        CapitalDecorator.new(@calculation_output.capital_subtotals.partner_capital_subtotals)
      end
    end
  end
end
