module V6
  class AssessmentsController < CreationController
    before_action :validate

    SelfEmployment = Data.define(:income, :client_reference)

    def create
      create = Creators::FullAssessmentCreator.call(remote_ip: request.remote_ip,
                                                    params: full_assessment_params)

      if create.success?
        self_employments = full_assessment_params.fetch(:employment_or_self_employment, [])
        partner_self_employments = full_assessment_params.dig(:partner, :employment_or_self_employment) || []
        calculation_output = Workflows::MainWorkflow.call(create.assessment,
                                                          parse_self_employments(self_employments),
                                                          parse_self_employments(partner_self_employments))

        render json: Decorators::V5::AssessmentDecorator.new(create.assessment, calculation_output).as_json
      else
        render_unprocessable(create.errors)
      end
    end

  private

    def parse_self_employments(self_employments)
      self_employments.map do |s|
        SelfEmployment.new client_reference: s[:client_reference],
                           income: SelfEmploymentIncome.new(s.fetch(:income))
      end
    end

    def validate
      validate_swagger_schema "/v6/assessments", full_assessment_params
    end

    def full_assessment_params
      @full_assessment_params ||= JSON.parse(request.raw_post, symbolize_names: true)
    end
  end
end
