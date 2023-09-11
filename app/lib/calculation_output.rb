class CalculationOutput
  delegate :income_contribution, :applicant_disposable_income_subtotals, :partner_disposable_income_subtotals,
           :combined_total_disposable_income, :combined_total_outgoings_and_allowances, to: :@disposable_income_subtotals

  # The assessment:, receives_qualifying_benefit:, receives_asylum_support: parameters are temporary whilst we refactor
  # the eligibilities objects. Once this is complete these parameters should be able to be be removed
  def initialize(capital_subtotals:,
                 proceeding_types:, receives_qualifying_benefit:, receives_asylum_support:, gross_income_subtotals:,
                 disposable_income_subtotals:)
    @capital_subtotals = capital_subtotals
    @gross_income_subtotals = gross_income_subtotals
    @disposable_income_subtotals = disposable_income_subtotals
    @proceeding_types = proceeding_types
    @receives_qualifying_benefit = receives_qualifying_benefit
    @receives_asylum_support = receives_asylum_support
    @results = Summarizers::MainSummarizer.call(proceeding_types:, receives_qualifying_benefit:, receives_asylum_support:,
                                                gross_income_eligibilities: @gross_income_subtotals.eligibilities,
                                                disposable_income_eligibilities: @disposable_income_subtotals.eligibilities,
                                                capital_eligibilities: @capital_subtotals.eligibilities)
  end

  attr_reader :capital_subtotals, :gross_income_subtotals, :receives_qualifying_benefit, :receives_asylum_support

  def assessment_result
    @results.assessment_result
  end

  def disposable_income_eligibilities
    @disposable_income_subtotals.eligibilities
  end

  def eligibilities
    @results.eligibilities
  end
end
