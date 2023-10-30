class CalculationOutput
  delegate :income_contribution, :applicant_disposable_income_subtotals, :partner_disposable_income_subtotals,
           :combined_total_disposable_income, :combined_total_outgoings_and_allowances, to: :@disposable_income_subtotals

  def initialize(gross_income_subtotals:, disposable_income_subtotals:, capital_subtotals:)
    @gross_income_subtotals = gross_income_subtotals
    @disposable_income_subtotals = disposable_income_subtotals
    @capital_subtotals = capital_subtotals
  end

  attr_reader :capital_subtotals, :gross_income_subtotals

  def disposable_income_eligibilities(proceeding_types)
    @disposable_income_subtotals.eligibilities proceeding_types
  end

  def disposable_income_assessment_results(proceeding_types)
    @disposable_income_subtotals.assessment_results proceeding_types
  end
end
