class CalculationOutput
  delegate :income_contribution, :applicant_disposable_income_subtotals, :partner_disposable_income_subtotals,
           :combined_total_disposable_income, :combined_total_outgoings_and_allowances, to: :@disposable_income_subtotals

  def initialize(capital_subtotals:,
                 assessment:, receives_qualifying_benefit:, receives_asylum_support:, gross_income_subtotals: GrossIncomeSubtotals.blank,
                 disposable_income_subtotals: DisposableIncomeSubtotals.blank)
    @capital_subtotals = capital_subtotals
    @gross_income_subtotals = gross_income_subtotals
    @disposable_income_subtotals = disposable_income_subtotals
    @assessment = assessment
    @receives_qualifying_benefit = receives_qualifying_benefit
    @receives_asylum_support = receives_asylum_support
  end

  def assessment_result
    Summarizers::MainSummarizer.call(assessment:, receives_qualifying_benefit:, receives_asylum_support:).assessment_result
  end

  attr_reader :capital_subtotals, :gross_income_subtotals, :assessment, :receives_qualifying_benefit, :receives_asylum_support
end
