class CalculationOutput
  delegate :applicant_disposable_income_subtotals, :partner_disposable_income_subtotals, to: :@disposable_income_subtotals

  def initialize(capital_subtotals:, gross_income_subtotals: GrossIncomeSubtotals.blank,
                 disposable_income_subtotals: DisposableIncomeSubtotals.blank)
    @capital_subtotals = capital_subtotals
    @gross_income_subtotals = gross_income_subtotals
    @disposable_income_subtotals = disposable_income_subtotals
  end

  attr_reader :capital_subtotals, :gross_income_subtotals
end
