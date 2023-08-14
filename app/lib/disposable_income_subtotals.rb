DisposableIncomeSubtotals = Data.define(:partner_disposable_income_subtotals,
                                        :applicant_disposable_income_subtotals,
                                        :income_contribution) do
  def self.blank
    new(partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
        applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
        income_contribution: 0)
  end
end
