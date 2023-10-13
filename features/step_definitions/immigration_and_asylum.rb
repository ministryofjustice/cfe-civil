Given("I am undertaking first tier controlled immigration assessment") do
  @assessment_data = { client_reference_id: "N/A", submission_date: "2022-05-10", level_of_help: "controlled" }
  @applicant_data = { date_of_birth: "1989-12-20",
                      involvement_type: "applicant",
                      has_partner_opponent: false,
                      receives_qualifying_benefit: false }
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: "DA001", client_involvement_type: "A" }] }
  @api_version = 6
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE, client_involvement_type: "A" }] }
end

Given("I am undertaking upper tribunal certificated immigration assessment") do
  @assessment_data = { client_reference_id: "N/A", submission_date: "2022-05-10", level_of_help: "certificated" }
  @applicant_data = { date_of_birth: "1989-12-20",
                      involvement_type: "applicant",
                      has_partner_opponent: false,
                      receives_qualifying_benefit: false }
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: "DA001", client_involvement_type: "A" }] }
  @api_version = 6
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE, client_involvement_type: "A" }] }
end

Given("I am undertaking upper tribunal certificated asylum assessment") do
  @assessment_data = { client_reference_id: "N/A", submission_date: "2022-05-10", level_of_help: "certificated" }
  @applicant_data = { date_of_birth: "1989-12-20",
                      involvement_type: "applicant",
                      has_partner_opponent: false,
                      receives_qualifying_benefit: false }
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: "DA001", client_involvement_type: "A" }] }
  @api_version = 6

  @proceeding_type_data = { "proceeding_types": [{ ccms_code: CFEConstants::ASYLUM_PROCEEDING_TYPE_CCMS_CODE, client_involvement_type: "A" }] }
end
