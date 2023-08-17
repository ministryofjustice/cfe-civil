module Decorators
  module V6
    class DisposableIncomeResultDecorator
      def initialize(summary, gross_income_summary, employment_income_subtotals, disposable_income_subtotals:, income_contribution:)
        @summary = summary
        @gross_income_summary = gross_income_summary
        @employment_income_subtotals = employment_income_subtotals
        @disposable_income_subtotals = disposable_income_subtotals
        @income_contribution = income_contribution
      end

      def as_json
        if @summary.is_a?(ApplicantDisposableIncomeSummary)
          basic_attributes.merge(proceeding_types:,
                                 income_contribution: @income_contribution.to_f,
                                 combined_total_disposable_income:,
                                 combined_total_outgoings_and_allowances:,
                                 partner_allowance:)
        else
          basic_attributes
        end
      end

      def basic_attributes
        {
          dependant_allowance_under_16: @disposable_income_subtotals.dependant_allowance_under_16,
          dependant_allowance_over_16: @disposable_income_subtotals.dependant_allowance_over_16,
          dependant_allowance: @disposable_income_subtotals.dependant_allowance,
          gross_housing_costs: @disposable_income_subtotals.gross_housing_costs.to_f,
          housing_benefit: @disposable_income_subtotals.housing_benefit.to_f,
          net_housing_costs: @disposable_income_subtotals.net_housing_costs.to_f,
          maintenance_allowance: @disposable_income_subtotals.maintenance_out_all_sources.to_f,
          total_outgoings_and_allowances: @summary.total_outgoings_and_allowances.to_f,
          total_disposable_income: @summary.total_disposable_income.to_f,
          employment_income:,
        }
      end

    private

      def employment_income
        {
          gross_income: @employment_income_subtotals.gross_employment_income.to_f,
          benefits_in_kind: @employment_income_subtotals.benefits_in_kind.to_f,
          tax: @employment_income_subtotals.tax.to_f,
          national_insurance: @employment_income_subtotals.national_insurance.to_f,
          fixed_employment_deduction: @employment_income_subtotals.fixed_employment_allowance.to_f,
          net_employment_income: @employment_income_subtotals.net_employment_income.to_f,
        }
      end

      def proceeding_types
        ProceedingTypesResultDecorator.new(@summary.eligibilities, @summary.assessment.proceeding_types).as_json
      end

      def partner_allowance
        @disposable_income_subtotals.partner_allowance
      end

      def combined_total_disposable_income
        @summary.combined_total_disposable_income.to_f
      end

      def combined_total_outgoings_and_allowances
        @summary.combined_total_outgoings_and_allowances.to_f
      end
    end
  end
end
