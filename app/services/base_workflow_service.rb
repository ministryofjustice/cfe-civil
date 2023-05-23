class BaseWorkflowService
  delegate :applicant,
           :submission_date,
           to: :assessment

  attr_reader :assessment

  def self.call(*args)
    new(*args).call
  end

  def initialize(assessment)
    @assessment = assessment
  end
end
