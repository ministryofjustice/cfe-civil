module V7
  class AssessmentsController < V6::AssessmentsController
  private

    def validate
      validate_swagger_schema "/v7/assessments", full_assessment_params
    end
  end
end
