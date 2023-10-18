class CalculationOutput
  delegate :income_contribution, :applicant_disposable_income_subtotals, :partner_disposable_income_subtotals,
           :combined_total_disposable_income, :combined_total_outgoings_and_allowances, to: :@disposable_income_subtotals

  # The receives_qualifying_benefit:, receives_asylum_support: parameters are temporary whilst we refactor
  # the eligibilities objects. Once this is complete these parameters should be able to be be removed
  def initialize(gross_income_subtotals:, disposable_income_subtotals:, capital_subtotals:,
                 receives_qualifying_benefit:, receives_asylum_support:)
    @gross_income_subtotals = gross_income_subtotals
    @disposable_income_subtotals = disposable_income_subtotals
    @capital_subtotals = capital_subtotals
    @receives_qualifying_benefit = receives_qualifying_benefit
    @receives_asylum_support = receives_asylum_support
  end

  attr_reader :capital_subtotals, :gross_income_subtotals, :receives_qualifying_benefit, :receives_asylum_support

  def disposable_income_eligibilities(proceeding_types)
    @disposable_income_subtotals.eligibilities proceeding_types
  end

  def assessment_results(proceeding_types)
    @assessment_results ||= Summarizers::MainSummarizer.assessment_results(proceeding_types:, receives_qualifying_benefit:,
                                                                           receives_asylum_support:,
                                                                           gross_income_assessment_results: @gross_income_subtotals.assessment_results(proceeding_types),
                                                                           disposable_income_assessment_results: @disposable_income_subtotals.assessment_results(proceeding_types),
                                                                           capital_assessment_results: @capital_subtotals.assessment_results(proceeding_types))
  end

  def summarized_assessment_result(proceeding_types)
    Utilities::ResultSummarizer.call(assessment_results(proceeding_types).values).to_s
  end
end
