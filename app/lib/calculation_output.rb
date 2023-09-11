class CalculationOutput
  delegate :income_contribution, :applicant_disposable_income_subtotals, :partner_disposable_income_subtotals,
           :combined_total_disposable_income, :combined_total_outgoings_and_allowances, to: :@disposable_income_subtotals

  # The assessment:, receives_qualifying_benefit:, receives_asylum_support: parameters are temporary whilst we refactor
  # the eligibilities objects. Once this is complete these parameters should be able to be be removed
  def initialize(capital_subtotals:,
                 assessment:, receives_qualifying_benefit:, receives_asylum_support:, gross_income_subtotals:,
                 disposable_income_subtotals:)
    @capital_subtotals = capital_subtotals
    @gross_income_subtotals = gross_income_subtotals
    @disposable_income_subtotals = disposable_income_subtotals
    @assessment = assessment
    @receives_qualifying_benefit = receives_qualifying_benefit
    @receives_asylum_support = receives_asylum_support
    @assessment_result = Summarizers::MainSummarizer.call(assessment:, receives_qualifying_benefit:, receives_asylum_support:,
                                                          gross_income_assessment_result: @gross_income_subtotals.summarized_assessment_result,
                                                          disposable_income_result: @disposable_income_subtotals.summarized_assessment_result).assessment_result
  end

  attr_reader :capital_subtotals, :gross_income_subtotals, :assessment, :receives_qualifying_benefit, :receives_asylum_support, :assessment_result

  def disposable_summarized_assessment_result
    @disposable_income_subtotals.summarized_assessment_result
  end

  def disposable_income_eligibilities
    @disposable_income_subtotals.eligibilities
  end
end
