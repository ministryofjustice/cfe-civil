module V6
  class AssessmentsController < CreationController
    before_action :validate, only: [:create]

    def create
      create = Creators::FullAssessmentCreator.call(remote_ip: request.remote_ip,
                                                    params: full_assessment_params)

      if create.success?
        self_employments = full_assessment_params.fetch(:employment_or_self_employment, [])
        calculation_output = if self_employments.any?
                               Workflows::MainWorkflow.call(create.assessment, self_employments.map do |s|
                                 SelfEmployment.new(s.fetch(:income).merge(
                                                      receiving_only_statutory_sick_or_maternity_pay: s.fetch(:receiving_only_statutory_sick_or_maternity_pay),
                                                    ))
                               end)
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
