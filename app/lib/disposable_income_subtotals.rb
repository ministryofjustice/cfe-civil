DisposableIncomeSubtotals = Data.define(:partner_disposable_income_subtotals,
                                        :applicant_disposable_income_subtotals,
                                        :income_contribution,
                                        :combined_total_disposable_income,
                                        :combined_total_outgoings_and_allowances) do
  def self.blank
    new(partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
        applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
        income_contribution: 0,
        combined_total_disposable_income: 0,
        combined_total_outgoings_and_allowances: 0)
  end
end
