module DisposableIncome
  class Base
    attr_reader :partner_disposable_income_subtotals, :applicant_disposable_income_subtotals

    def initialize(partner_disposable_income_subtotals:, applicant_disposable_income_subtotals:)
      @partner_disposable_income_subtotals = partner_disposable_income_subtotals
      @applicant_disposable_income_subtotals = applicant_disposable_income_subtotals
    end

    def combined_total_disposable_income
      applicant_disposable_income_subtotals.total_disposable_income +
        partner_disposable_income_subtotals.total_disposable_income
    end

    def combined_total_outgoings_and_allowances
      applicant_disposable_income_subtotals.total_outgoings_and_allowances +
        partner_disposable_income_subtotals.total_outgoings_and_allowances
    end
  end
end
