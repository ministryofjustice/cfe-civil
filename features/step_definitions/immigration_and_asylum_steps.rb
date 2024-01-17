class AssessmentData
  class << self
    def assessment(level_of_help:)
      {
        client_reference_id: "N/A",
        submission_date: "2022-05-10",
        level_of_help:,
      }
    end

    def applicant
      {
        date_of_birth: "1989-12-20",
        receives_qualifying_benefit: false,
      }
    end

    def proceeding_types(ccms_code:)
      {
        "proceeding_types": [
          { ccms_code:, client_involvement_type: "A" },
        ],
      }
    end
  end
end

Given("I am undertaking first tier controlled immigration assessment") do
  @assessment_data = AssessmentData.assessment(level_of_help: "controlled")
  @applicant_data = AssessmentData.applicant
  @proceeding_type_data = AssessmentData.proceeding_types(ccms_code: CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE)
  @api_version = 6
end

Given("I am undertaking first tier controlled asylum assessment") do
  @assessment_data = AssessmentData.assessment(level_of_help: "controlled")
  @applicant_data = AssessmentData.applicant
  @proceeding_type_data = AssessmentData.proceeding_types(ccms_code: CFEConstants::ASYLUM_PROCEEDING_TYPE_CCMS_CODE)
  @api_version = 6
end

Given("I am undertaking upper tribunal certificated immigration assessment") do
  @assessment_data = AssessmentData.assessment(level_of_help: "certificated")
  @applicant_data = AssessmentData.applicant
  @proceeding_type_data = AssessmentData.proceeding_types(ccms_code: CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE)
  @api_version = 6
end

Given("I am undertaking upper tribunal certificated asylum assessment") do
  @assessment_data = AssessmentData.assessment(level_of_help: "certificated")
  @applicant_data = AssessmentData.applicant
  @proceeding_type_data = AssessmentData.proceeding_types(ccms_code: CFEConstants::ASYLUM_PROCEEDING_TYPE_CCMS_CODE)
  @api_version = 6
  @employments = []
end

Given("The applicant is receiving asylum support") do
  @applicant_data.merge!(receives_asylum_support: true)
end
