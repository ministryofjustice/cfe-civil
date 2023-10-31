class EligibilityResults
  def initialize(proceeding_types:, receives_qualifying_benefit:, receives_asylum_support:, submission_date:,
                 gross_income_assessment_results:, disposable_income_assessment_results:, capital_assessment_results:)
    @proceeding_types = proceeding_types
    @receives_qualifying_benefit = receives_qualifying_benefit
    @receives_asylum_support =   receives_asylum_support
    @submission_date = submission_date
    @gross_income_assessment_results = gross_income_assessment_results
    @disposable_income_assessment_results = disposable_income_assessment_results
    @capital_assessment_results = capital_assessment_results
  end

  def assessment_results
    @assessment_results ||= Summarizers::MainSummarizer.assessment_results(proceeding_types: @proceeding_types,
                                                                           receives_qualifying_benefit: @receives_qualifying_benefit,
                                                                           receives_asylum_support: @receives_asylum_support,
                                                                           submission_date: @submission_date,
                                                                           gross_income_assessment_results: @gross_income_assessment_results,
                                                                           disposable_income_assessment_results: @disposable_income_assessment_results,
                                                                           capital_assessment_results: @capital_assessment_results)
  end

  def summarized_assessment_result
    Utilities::ResultSummarizer.call(assessment_results.values).to_s
  end
end
