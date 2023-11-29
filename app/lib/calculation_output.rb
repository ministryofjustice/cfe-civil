class CalculationOutput
  delegate :income_contribution, :applicant_disposable_income_subtotals, :partner_disposable_income_subtotals,
           :combined_total_disposable_income, :combined_total_outgoings_and_allowances, to: :@disposable_income_subtotals

  delegate :combined_assessed_capital, to: :capital_subtotals

  attr_reader :level_of_help, :submission_date, :capital_subtotals, :gross_income_subtotals

  def initialize(submission_date:, level_of_help:, gross_income_subtotals:, disposable_income_subtotals:, capital_subtotals:)
    @submission_date = submission_date
    @level_of_help = level_of_help
    @gross_income_subtotals = gross_income_subtotals
    @disposable_income_subtotals = disposable_income_subtotals
    @capital_subtotals = capital_subtotals
  end

  def disposable_income_assessed?
    @disposable_income_subtotals.assessed?
  end
end
