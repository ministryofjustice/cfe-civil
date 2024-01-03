module Decorators
  module V6
    class ResultSummaryDecorator
      attr_reader :assessment

      def initialize(assessment:, calculation_output:, partner_present:, eligibility_result:)
        @assessment = assessment
        @calculation_output = calculation_output
        @partner_present = partner_present
        @eligibility_result = eligibility_result
      end

      def as_json
        capital_contribution = @calculation_output.capital_subtotals.capital_contribution(assessment.proceeding_types).to_f
        income_contribution = @calculation_output.income_contribution(assessment.proceeding_types)

        assessment_results = @eligibility_result.assessment_results.map do |proceeding_type, result|
          {
            ccms_code: proceeding_type.ccms_code,
            upper_threshold: 0.0,
            lower_threshold: 0.0,
            result:,
            client_involvement_type: proceeding_type.client_involvement_type,
          }
        end

        details = {
          overall_result: {
            result: @eligibility_result.summarized_assessment_result,
            capital_contribution:,
            income_contribution:,
            proceeding_types: assessment_results.as_json,
          },
          gross_income: ApplicantGrossIncomeResultDecorator.new(
            total_gross_income: @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.total_gross_income,
            combined_monthly_gross_income: @calculation_output.gross_income_subtotals.combined_monthly_gross_income,
            eligibilities: @eligibility_result.gross_eligibilities,
          ),
          disposable_income: applicant_disposable_income_result_decorator_class.new(
            assessment.applicant_disposable_income_summary,
            assessment.applicant_gross_income_summary,
            @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals,
            disposable_income_subtotals: @calculation_output.applicant_disposable_income_subtotals,
            combined_total_disposable_income: @calculation_output.combined_total_disposable_income,
            combined_total_outgoings_and_allowances: @calculation_output.combined_total_outgoings_and_allowances,
            income_contribution:,
            eligibilities: @eligibility_result.disposable_eligibilities,
          ),
          capital: ApplicantCapitalResultDecorator.new(
            applicant_capital_subtotals: @calculation_output.capital_subtotals.applicant_capital_subtotals,
            partner_capital_subtotals: @calculation_output.capital_subtotals.partner_capital_subtotals,
            capital_contribution:,
            combined_assessed_capital: @calculation_output.capital_subtotals.combined_assessed_capital.to_f,
            eligibilities: @eligibility_result.capital_eligibilities,
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
        disposable_income_result_decorator_class.new(
          assessment.partner_disposable_income_summary,
          assessment.partner_gross_income_summary,
          @calculation_output.gross_income_subtotals.partner_gross_income_subtotals.employment_income_subtotals,
          disposable_income_subtotals: @calculation_output.partner_disposable_income_subtotals,
        )
      end

      def partner_capital
        CapitalResultDecorator.new(@calculation_output.capital_subtotals.partner_capital_subtotals)
      end

    private

      def applicant_disposable_income_result_decorator_class
        ApplicantDisposableIncomeResultDecorator
      end

      def disposable_income_result_decorator_class
        DisposableIncomeResultDecorator
      end
    end
  end
end
