class CalculationOutput
  delegate :income_contribution, :applicant_disposable_income_subtotals, :partner_disposable_income_subtotals,
           :combined_total_disposable_income, :combined_total_outgoings_and_allowances, to: :@disposable_income_subtotals

  def initialize(capital_subtotals:, assessment_result:, gross_income_subtotals: GrossIncomeSubtotals.blank,
                 disposable_income_subtotals: DisposableIncomeSubtotals.blank)
    @capital_subtotals = capital_subtotals
    @gross_income_subtotals = gross_income_subtotals
    @disposable_income_subtotals = disposable_income_subtotals
    @assessment_result = assessment_result
  end

  attr_reader :capital_subtotals, :gross_income_subtotals, :assessment_result
end
