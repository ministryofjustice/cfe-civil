class ResultWrapper
  Eligibility = Data.define(:proceeding_type, :upper_threshold, :lower_threshold, :assessment_result)

  def initialize(result:, gross_section:, disposable_section:, capital_section:)
    @result = result
    @gross_section = gross_section
    @disposable_section = disposable_section
    @capital_section = capital_section
  end

  def assessment_results
    @result.assessment_results.transform_values do |r|
      gross = transform_result(r, @gross_section)
      disposable = transform_disposable_result(gross)
      transform_result(disposable, @capital_section)
    end
  end

  def summarized_assessment_result
    Utilities::ResultSummarizer.call(assessment_results.values)
  end

  def gross_eligibilities
    @result.gross_eligibilities.map { |eligibility| map_eligibility(eligibility, @gross_section) }
  end

  def disposable_eligibilities
    @result.disposable_eligibilities.map do |eligibility|
      Eligibility.new(proceeding_type: eligibility.proceeding_type,
                      upper_threshold: eligibility.upper_threshold,
                      lower_threshold: eligibility.lower_threshold,
                      assessment_result: transform_disposable_result(eligibility.assessment_result.to_sym))
    end
  end

  def capital_eligibilities
    @result.capital_eligibilities.map { |eligibility| map_eligibility(eligibility, @capital_section) }
  end

private

  def map_eligibility(eligibility, section)
    Eligibility.new(proceeding_type: eligibility.proceeding_type,
                    upper_threshold: eligibility.upper_threshold,
                    lower_threshold: eligibility.lower_threshold,
                    assessment_result: transform_result(eligibility.assessment_result.to_sym, section))
  end

  def transform_result(value, section)
    if value != :ineligible && section == "incomplete"
      :not_yet_known
    else
      value
    end
  end

  def transform_disposable_result(value)
    if value != :eligible && @disposable_section == "incomplete"
      :not_yet_known
    else
      value
    end
  end
end
