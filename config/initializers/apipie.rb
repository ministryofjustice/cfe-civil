Dir[File.join(__dir__, "../../app/validators", "*.rb")].sort.each { |file| require file }

Apipie.configure do |config|
  config.app_name                = "Check Financial Base API"
  config.api_base_url            = "/"
  config.doc_base_url            = "/apidocs"
  config.api_routes = Rails.application.routes
  # where is your API defined?
  config.api_controllers_matcher = Rails.root.join("app/controllers/**/*.rb")
  config.translate = false
  config.validate = true
  config.show_all_examples = true
  config.layout = "apipie_override"
  config.ignore_allow_blank_false = true
  config.app_info = <<-END_OF_TEXT


    == Check Financial Base API

    = Overview
    This API is used to determine the finanical eligibility of an applicant for Legal Aid

    == Usage
    The first step is to create an assessment via:

      POST /assessments

    The response to this action includes an assessment id that can then be used in the following steps:

      POST /assessments/:assessment_id/vehicles           # adds data about vehicles owned by the applicant

    Once all the above calls have been made to build up a complete picture of the applicant's assets and income
    the following call should be made to perform the assessment and get the result:

      GET /assessment/:assessment_id
  END_OF_TEXT
end
