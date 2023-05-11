module V6
  class AssessmentsController < CreationController
    before_action :validate, only: [:create]

    def create
      create = Creators::FullAssessmentCreator.call(remote_ip: request.remote_ip,
                                                    params: full_assessment_params)

      if create.success?
        self_employment = full_assessment_params[:employment_or_self_employment]
        calculation_output = if self_employment.present?
                               Workflows::MainWorkflow.call(create.assessment, SelfEmployment.new(self_employment))
                             else
                               Workflows::MainWorkflow.call(create.assessment)
                             end
        render json: Decorators::V5::AssessmentDecorator.new(create.assessment, calculation_output).as_json
      else
        render_unprocessable(create.errors)
      end
    end

  private

    def validate
      validate_swagger_schema "/v6/assessments", full_assessment_params
    end

    def full_assessment_params
      JSON.parse(request.raw_post, symbolize_names: true)
    end
  end
end
