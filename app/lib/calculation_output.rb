class CalculationOutput
  delegate :dependant_allowance, :partner_dependant_allowance, to: :@disposable_income_subtotals

  def initialize(gross_income_subtotals: GrossIncomeSubtotals.new,
                 capital_subtotals: CapitalSubtotals.new, disposable_income_subtotals: DisposableIncomeSubtotals.new)
    @capital_subtotals = capital_subtotals
    @gross_income_subtotals = gross_income_subtotals
    @disposable_income_subtotals = disposable_income_subtotals
  end

  attr_reader :capital_subtotals, :gross_income_subtotals
end
