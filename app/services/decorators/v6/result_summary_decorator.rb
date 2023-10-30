module Decorators
  module V6
    class ResultSummaryDecorator
      attr_reader :assessment

      def initialize(assessment:, calculation_output:, partner_present:, receives_qualifying_benefit:, receives_asylum_support:, submission_date:)
        @assessment = assessment
        @calculation_output = calculation_output
        @partner_present = partner_present
        @receives_qualifying_benefit = receives_qualifying_benefit
        @receives_asylum_support =   receives_asylum_support
        @submission_date = submission_date
      end

      def as_json
        capital_contribution = @calculation_output.capital_subtotals.capital_contribution(assessment.proceeding_types).to_f
        income_contribution = @calculation_output.income_contribution(assessment.proceeding_types)

        assessment_results = @calculation_output.assessment_results(proceeding_types: assessment.proceeding_types,
                                                                    submission_date: @submission_date,
                                                                    receives_qualifying_benefit: @receives_qualifying_benefit,
                                                                    receives_asylum_support: @receives_asylum_support).map do |proceeding_type, result|
          {
            ccms_code: proceeding_type.ccms_code,
            upper_threshold: 0.0,
            lower_threshold: 0.0,
            result:,
          }.tap do |hash|
            hash[:client_involvement_type] = proceeding_type.client_involvement_type if proceeding_type.client_involvement_type.present?
          end
        end

        details = {
          overall_result: {
            result: @calculation_output.summarized_assessment_result(proceeding_types: assessment.proceeding_types,
                                                                     submission_date: @submission_date,
                                                                     receives_qualifying_benefit: @receives_qualifying_benefit,
                                                                     receives_asylum_support: @receives_asylum_support),
            capital_contribution:,
            income_contribution:,
            proceeding_types: assessment_results.as_json,
          },
          gross_income: ApplicantGrossIncomeResultDecorator.new(gross_income_subtotals: @calculation_output.gross_income_subtotals,
                                                                proceeding_types: assessment.proceeding_types),
          disposable_income: ApplicantDisposableIncomeResultDecorator.new(
            assessment.applicant_disposable_income_summary,
            assessment.applicant_gross_income_summary,
            @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals,
            disposable_income_subtotals: @calculation_output.applicant_disposable_income_subtotals,
            combined_total_disposable_income: @calculation_output.combined_total_disposable_income,
            combined_total_outgoings_and_allowances: @calculation_output.combined_total_outgoings_and_allowances,
            income_contribution:,
            eligibilities: @calculation_output.disposable_income_eligibilities(assessment.proceeding_types),
          ),
          capital: ApplicantCapitalResultDecorator.new(
            summary: assessment.applicant_capital_summary,
            applicant_capital_subtotals: @calculation_output.capital_subtotals.applicant_capital_subtotals,
            partner_capital_subtotals: @calculation_output.capital_subtotals.partner_capital_subtotals,
            capital_contribution:,
            combined_assessed_capital: @calculation_output.capital_subtotals.combined_assessed_capital.to_f,
            eligibilities: @calculation_output.capital_subtotals.eligibilities(assessment.proceeding_types),
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
        GrossIncomeResultDecorator.new(@calculation_output.gross_income_subtotals.partner_gross_income_subtotals.total_gross_income)
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
