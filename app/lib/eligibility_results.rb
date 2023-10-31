class EligibilityResults
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
    Utilities::ResultSummarizer.call(assessment_results.values).to_s
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
