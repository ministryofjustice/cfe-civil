module Decorators
  module V6
    class DisposableIncomeDecorator
      attr_reader :record, :categories

      def initialize(disposable_income_subtotals:, state_benefits:)
        @disposable_income_subtotals = disposable_income_subtotals
        @categories = CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
        @state_benefits = state_benefits
      end

      def as_json
        {
          monthly_equivalents:,
          childcare_allowance:,
          deductions:,
        }
      end

    private

      def monthly_equivalents
        {
          all_sources: transactions(:all_sources),
          bank_transactions: transactions(:bank),
          cash_transactions: transactions(:cash),
        }
      end

      def transactions(source)
        {
          child_care: @disposable_income_subtotals.__send__("child_care_#{source}").to_f,
          rent_or_mortgage: @disposable_income_subtotals.__send__("rent_or_mortgage_#{source}").to_f,
          maintenance_out: @disposable_income_subtotals.__send__("maintenance_out_#{source}").to_f,
          legal_aid: @disposable_income_subtotals.__send__("legal_aid_#{source}").to_f,
          pension_contribution: @disposable_income_subtotals.__send__("pension_contribution_#{source}").to_f,
          council_tax: @disposable_income_subtotals.__send__("council_tax_#{source}").to_f,
          priority_debt_repayment: @disposable_income_subtotals.__send__("priority_debt_repayment_#{source}").to_f,
        }
      end

      def childcare_allowance
        @disposable_income_subtotals.child_care_all_sources.to_f
      end

      def deductions
        {
          dependants_allowance: @disposable_income_subtotals.dependant_allowance.to_f,
          disregarded_state_benefits: Calculators::DisregardedStateBenefitsCalculator.call(@state_benefits).to_f,
        }
      end
    end
  end
end
