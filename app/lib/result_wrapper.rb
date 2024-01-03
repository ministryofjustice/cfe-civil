class ResultWrapper
  Eligibility = Data.define(:proceeding_type, :upper_threshold, :lower_threshold, :assessment_result)

  def initialize(result:, gross_section:, disposable_section:, capital_section:)
    @result = result
    @gross_section = gross_section
    @disposable_section = disposable_section
    @capital_section = capital_section
  end

  def assessment_results
    @result.assessment_results.transform_values do |assessment_result|
      gross = transform_gross_result(assessment_result.assessment_result, assessment_result.sections)
      disposable = transform_disposable_result(assessment_result.assessment_result, assessment_result.sections)
      capital = transform_capital_result(assessment_result.assessment_result, assessment_result.sections)
      result = if [gross, disposable, capital].include?(:ineligible)
                 :ineligible
               else
                 Utilities::ResultSummarizer.call [gross, disposable, capital]
               end
      EligibilityResults::Result.new assessment_result: result, sections: assessment_result.sections
    end
  end

  def summarized_assessment_result
    Utilities::ResultSummarizer.call(assessment_results.values.map(&:assessment_result))
  end

  def gross_eligibilities
    @result.gross_eligibilities.map { |eligibility| map_gross_eligibility(eligibility) }
  end

  def disposable_eligibilities
    @result.disposable_eligibilities.map do |eligibility|
      result_sections = result_sections_for(eligibility.proceeding_type)
      Eligibility.new(proceeding_type: eligibility.proceeding_type,
                      upper_threshold: eligibility.upper_threshold,
                      lower_threshold: eligibility.lower_threshold,
                      assessment_result: transform_disposable_result(eligibility.assessment_result.to_sym, result_sections))
    end
  end

  def capital_eligibilities
    @result.capital_eligibilities.map { |eligibility| map_capital_eligibility(eligibility) }
  end

private

  def result_sections_for(proceeding_type)
    @result.assessment_results.fetch(proceeding_type).sections
  end

  def map_gross_eligibility(eligibility)
    result_sections = result_sections_for(eligibility.proceeding_type)
    Eligibility.new(proceeding_type: eligibility.proceeding_type,
                    upper_threshold: eligibility.upper_threshold,
                    lower_threshold: eligibility.lower_threshold,
                    assessment_result: transform_gross_result(eligibility.assessment_result.to_sym, result_sections))
  end

  def map_capital_eligibility(eligibility)
    result_sections = @result.assessment_results.fetch(eligibility.proceeding_type).sections
    Eligibility.new(proceeding_type: eligibility.proceeding_type,
                    upper_threshold: eligibility.upper_threshold,
                    lower_threshold: eligibility.lower_threshold,
                    assessment_result: transform_capital_result(eligibility.assessment_result.to_sym, result_sections))
  end

  def transform_gross_result(value, result_sections)
    if value != :ineligible && @gross_section == "incomplete"
      :not_yet_known
    elsif @gross_section == "complete" && result_sections.exclude?(:gross) && value != :not_calculated
      :eligible
    else
      value
    end
  end

  def transform_disposable_result(value, result_sections)
    if value != :eligible && result_sections.include?(:disposable) && @disposable_section == "incomplete"
      :not_yet_known
    else
      value
    end
  end

  def transform_capital_result(value, result_sections)
    if value != :ineligible && @capital_section == "incomplete"
      :not_yet_known
    elsif result_sections.exclude?(:capital)
      :eligible
    else
      value
    end
  end
end
