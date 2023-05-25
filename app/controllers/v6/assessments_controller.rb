module V6
  class AssessmentsController < ApplicationController
    before_action :validate

    SelfEmployment = Data.define(:income, :client_reference)

    def create
      create = Creators::FullAssessmentCreator.call(remote_ip: request.remote_ip,
                                                    params: full_assessment_params)

      if create.success?
        calculation_output = Workflows::MainWorkflow.call(assessment: create.assessment,
                                                          applicant: person_data(full_assessment_params),
                                                          partner: person_data(full_assessment_params.fetch(:partner, {})))

        render json: Decorators::V6::AssessmentDecorator.new(create.assessment, calculation_output).as_json
      else
        render_unprocessable(create.errors)
      end
    end

  private

    def person_data(input_params)
      self_employments = parse_self_employments(input_params.fetch(:employment_or_self_employment, []))
      vehicles = parse_vehicles(input_params.fetch(:vehicles, []))
      PersonData.new(self_employments:, vehicles:)
    end

    def parse_vehicles(vehicles)
      vehicles.map do |v|
        x = v.merge(date_of_purchase: Date.parse(v.fetch(:date_of_purchase)),
                    subject_matter_of_dispute: v.fetch(:subject_matter_of_dispute, false))
        Vehicle.new(**x)
      end
    end

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
