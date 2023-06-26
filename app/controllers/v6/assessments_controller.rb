module V6
  class AssessmentsController < ApplicationController
    before_action :validate

    EmploymentOrSelfEmploymentDetails = Data.define(:income, :client_reference)

    def create
      create = Creators::FullAssessmentCreator.call(remote_ip: request.remote_ip,
                                                    params: full_assessment_params)
      if create.success?
        applicant_dependants = dependants full_assessment_params, create.assessment.submission_date
        render_unprocessable(dependant_errors(applicant_dependants)) && return if applicant_dependants.reject(&:valid?).any?

        applicant_model = Applicant.new(full_assessment_params.fetch(:applicant, {}))
        render_unprocessable(applicant_model.errors.full_messages) && return unless applicant_model.valid?

        applicant = person_data(full_assessment_params,
                                applicant_dependants,
                                applicant_model)

        partner_params = full_assessment_params[:partner]
        if partner_params.present?
          partner_dependants = dependants partner_params, create.assessment.submission_date
          render_unprocessable(dependant_errors(partner_dependants)) && return if partner_dependants.reject(&:valid?).any?

          partner_model = Applicant.new(partner_params.fetch(:partner, {}))
          render_unprocessable(partner_model.errors.full_messages) && return unless partner_model.valid?

          partner = person_data(partner_params,
                                partner_dependants,
                                partner_model)

          calculation_output = Workflows::MainWorkflow.call(assessment: create.assessment,
                                                            applicant:,
                                                            partner:)
        else
          calculation_output = Workflows::MainWorkflow.call(assessment: create.assessment,
                                                            applicant:,
                                                            partner: nil)
        end
        render json: Decorators::V6::AssessmentDecorator.new(assessment: create.assessment, calculation_output:, applicant:, partner:).as_json
      else
        render_unprocessable(create.errors)
      end
    end

  private

    def dependants(input_params, submission_date)
      dependant_params = input_params.fetch(:dependants, [])
      dependant_params.map { |p| Dependant.new(p.merge(submission_date:)) }
    end

    def dependant_errors(dependants)
      dependants.reject(&:valid?).map { |m| m.errors.full_messages }.reduce([], &:+)
    end

    def person_data(input_params, dependants, applicant)
      PersonData.new(details: applicant.freeze,
                     employment_details: parse_employment_details(input_params.fetch(:employment_details, [])),
                     self_employments: parse_self_employments(input_params.fetch(:self_employment_details, [])),
                     vehicles: parse_vehicles(input_params.fetch(:vehicles, [])),
                     dependants: dependants.map(&:freeze))
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
        EmploymentOrSelfEmploymentDetails.new client_reference: s[:client_reference],
                                              income: SelfEmploymentIncome.new(s.fetch(:income)).freeze
      end
    end

    def parse_employment_details(employments)
      employments.map do |s|
        EmploymentOrSelfEmploymentDetails.new client_reference: s[:client_reference],
                                              income: EmploymentIncome.new(s.fetch(:income)).freeze
      end
    end

    def validate
      validate_swagger_schema "/v6/assessments", full_assessment_params
    end

    def full_assessment_params
      @full_assessment_params ||= JSON.parse(request.raw_post, symbolize_names: true, decimal_class: BigDecimal)
    end
  end
end
