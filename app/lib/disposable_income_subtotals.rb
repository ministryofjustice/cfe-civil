class DisposableIncomeSubtotals
  class << self
    def blank
      new(partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
          applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank)
    end
  end
  attr_reader :partner_disposable_income_subtotals, :applicant_disposable_income_subtotals

  def initialize(partner_disposable_income_subtotals:, applicant_disposable_income_subtotals:)
    @partner_disposable_income_subtotals = partner_disposable_income_subtotals
    @applicant_disposable_income_subtotals = applicant_disposable_income_subtotals
  end
end
