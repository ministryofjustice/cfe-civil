module Decorators
  module V6
    class AssessmentDecorator
      attr_reader :assessment

      def initialize(assessment:, calculation_output:, applicant:, partner:, version:, eligibility_result:)
        @assessment = assessment
        @calculation_output = calculation_output
        @applicant = applicant
        @partner = partner
        @version = version
        @eligibility_result = eligibility_result
      end

      def as_json
        {
          version: @version,
          timestamp: Time.current,
          success: true,
          result_summary: ResultSummaryDecorator.new(assessment:, calculation_output: @calculation_output,
                                                     eligibility_result: @eligibility_result,
                                                     partner_present: @partner.present?).as_json,
          assessment: assessment_details.transform_values(&:as_json),
        }
      end

    private

      def assessment_details
        # summarized_assessment_result = @calculation_output.summarized_assessment_result(proceeding_types: assessment.proceeding_types,
        #                                                                                 submission_date: assessment.submission_date,
        #                                                                                 receives_asylum_support: @applicant.details.receives_asylum_support,
        #                                                                                 receives_qualifying_benefit: @applicant.details.receives_qualifying_benefit)
        details = {
          id: assessment.id,
          client_reference_id: assessment.client_reference_id,
          submission_date: assessment.submission_date,
          level_of_help: assessment.level_of_help,
          applicant: applicant_decorator_class.new(@applicant.details),
          gross_income:,
          disposable_income: DisposableIncomeDecorator.new(
            summary: assessment.applicant_disposable_income_summary,
            disposable_income_subtotals: @calculation_output.applicant_disposable_income_subtotals,
            state_benefits: @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.state_benefits,
          ),
          capital: CapitalDecorator.new(assessment.applicant_capital_summary,
                                        @calculation_output.capital_subtotals.applicant_capital_subtotals),
          remarks: RemarksDecorator.new(assessment.remarks, @eligibility_result.summarized_assessment_result),
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

      def gross_income
        GrossIncomeDecorator.new(assessment.applicant_gross_income_summary,
                                 @applicant.employments,
                                 @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals)
      end

      def partner_gross_income
        GrossIncomeDecorator.new(assessment.partner_gross_income_summary,
                                 @partner.employments,
                                 @calculation_output.gross_income_subtotals.partner_gross_income_subtotals)
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
