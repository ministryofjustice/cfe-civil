class EligibilityResults
  class BlankEligibilityResult
    def initialize(proceeding_types)
      @proceeding_types = proceeding_types
    end

    def assessment_results
      @proceeding_types.index_with { :eligible }
    end

    def summarized_assessment_result
      :eligible
    end

    # This is used when the assessment is non means tested so there are no thresholds
    # worth reporting anything about
    def gross_eligibilities
      []
    end

    def disposable_eligibilities
      []
    end

    def capital_eligibilities
      []
    end
  end

  class << self
    def without_partner(proceeding_types:, submission_date:,
                        applicant:, level_of_help:)
      new(proceeding_types:, submission_date:,
          applicant:, level_of_help:, partner: nil)
    end

    def with_partner(proceeding_types:, submission_date:,
                     applicant:, level_of_help:, partner:)
      new(proceeding_types:, submission_date:,
          applicant:, level_of_help:, partner:)
    end
  end

  def initialize(proceeding_types:, submission_date:,
                 applicant:, partner:, level_of_help:)
    @proceeding_types = proceeding_types
    @submission_date = submission_date
    @applicant = applicant
    @partner = partner
    @level_of_help = level_of_help
  end

  def assessment_results
    if @proceeding_types.size == 1
      { @proceeding_types.first => workflow_results(@proceeding_types).assessment_result }
    else
      outputs = @proceeding_types.map do |proceeding_type|
        [proceeding_type, workflow_results([proceeding_type]).assessment_result]
      end
      outputs.to_h
    end
  end

  def summarized_assessment_result
    Utilities::ResultSummarizer.call(assessment_results.values)
  end

  def gross_eligibilities
    subtotals = workflow_results(@proceeding_types).calculation_output.gross_income_subtotals
    if subtotals.assessed?
      Creators::GrossIncomeEligibilityCreator.call(
        dependants: subtotals.dependants,
        proceeding_types: @proceeding_types,
        submission_date: @submission_date,
        level_of_help: @level_of_help,
        total_gross_income: subtotals.combined_monthly_gross_income,
      )
    else
      Creators::GrossIncomeEligibilityCreator.unassessed(
        proceeding_types: @proceeding_types,
        submission_date: @submission_date,
        level_of_help: @level_of_help,
      )
    end
  end

  def disposable_eligibilities
    calculation_output = workflow_results(@proceeding_types).calculation_output
    if calculation_output.disposable_income_assessed?
      Creators::DisposableIncomeEligibilityCreator.call(
        proceeding_types: @proceeding_types,
        submission_date: @submission_date,
        level_of_help: @level_of_help,
        total_disposable_income: calculation_output.combined_total_disposable_income,
      )
    else
      Creators::DisposableIncomeEligibilityCreator.unassessed(
        proceeding_types: @proceeding_types,
        submission_date: @submission_date,
        level_of_help: @level_of_help,
      )
    end
  end

  def capital_eligibilities
    subtotals = workflow_results(@proceeding_types).calculation_output.capital_subtotals
    if subtotals.assessed?
      Creators::CapitalEligibilityCreator.call proceeding_types: @proceeding_types,
                                               submission_date: @submission_date,
                                               level_of_help: @level_of_help,
                                               assessed_capital: subtotals.combined_assessed_capital
    else
      Creators::CapitalEligibilityCreator.unassessed proceeding_types: @proceeding_types,
                                                     submission_date: @submission_date,
                                                     level_of_help: @level_of_help
    end
  end

private

  def workflow_results(proceeding_types)
    if @partner.present?
      Workflows::MainWorkflow.with_partner(applicant: @applicant, proceeding_types:,
                                           level_of_help: @level_of_help,
                                           partner: @partner,
                                           submission_date: @submission_date)
    else
      Workflows::MainWorkflow.without_partner(applicant: @applicant, proceeding_types:,
                                              level_of_help: @level_of_help,
                                              submission_date: @submission_date)
    end
  end
end
