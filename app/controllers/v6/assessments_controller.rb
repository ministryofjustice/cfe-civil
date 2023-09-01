module V6
  class AssessmentsController < ApplicationController
    before_action :validate

    EmploymentOrSelfEmploymentDetails = Data.define(:income, :client_reference)

    def create
      create = Creators::FullAssessmentCreator.call(remote_ip: request.remote_ip,
                                                    params: full_assessment_params, version:)
      if create.success?
        applicant_dependants = dependants full_assessment_params, create.assessment.submission_date
        render_unprocessable(dependant_errors(applicant_dependants)) && return if applicant_dependants.reject(&:valid?).any?

        applicant_model = Applicant.new(full_assessment_params.fetch(:applicant, {}))
        render_unprocessable(applicant_model.errors.full_messages) && return unless applicant_model.valid?

        applicant = person_data(full_assessment_params,
                                applicant_dependants,
                                applicant_model,
                                full_assessment_params.fetch(:properties, {})[:main_home],
                                full_assessment_params.fetch(:properties, {}).fetch(:additional_properties, []))

        partner_params = full_assessment_params[:partner]
        if partner_params.present?
          partner_dependants = dependants partner_params, create.assessment.submission_date
          render_unprocessable(dependant_errors(partner_dependants)) && return if partner_dependants.reject(&:valid?).any?

          partner_model = Applicant.new(partner_params.fetch(:partner, {}))
          render_unprocessable(partner_model.errors.full_messages) && return unless partner_model.valid?

          partner = person_data(partner_params,
                                partner_dependants,
                                partner_model,
                                nil,
                                partner_params.fetch(:additional_properties, []))

          calculation_output = Workflows::MainWorkflow.call(assessment: create.assessment,
                                                            applicant:,
                                                            partner:)
        else
          calculation_output = Workflows::MainWorkflow.call(assessment: create.assessment,
                                                            applicant:,
                                                            partner: nil)
        end
        render json: assessment_decorator_class.new(assessment: create.assessment, calculation_output:, applicant:, partner:).as_json
      else
        render_unprocessable(create.errors)
      end
    end

  private

    def assessment_decorator_class
      Decorators::V6::AssessmentDecorator
    end

    def dependants(input_params, submission_date)
      dependant_params = input_params.fetch(:dependants, [])
      dependant_params.map do |params|
        updated_params = convert_monthly_income_params(params)
        Dependant.new(updated_params.merge(submission_date:))
      end
    end

    def convert_monthly_income_params(params)
      income = params[:income]
      monthly_income = params[:monthly_income]
      if income.present?
        income_amount = income[:amount]
        income_frequency = income[:frequency]
        params.except(:monthly_income, :income).merge(income_amount:, income_frequency:)
      elsif monthly_income.present?
        income_amount = monthly_income
        income_frequency = CFEConstants::MONTHLY_FREQUENCY
        params.except(:monthly_income, :income).merge(income_amount:, income_frequency:)
      else
        params
      end
    end

    def dependant_errors(dependants)
      dependants.reject(&:valid?).map { |m| m.errors.full_messages }.reduce([], &:+)
    end

    def person_data(input_params, dependants, applicant, main_home, additional_properties)
      capitals = input_params.fetch(:capitals, {})
      capitals_data = CapitalsData.new(vehicles: parse_vehicles(input_params.fetch(:vehicles, [])),
                                       main_home: main_home.present? ? parse_main_home(main_home) : nil,
                                       additional_properties: parse_additional_properties(additional_properties),
                                       liquid_capital_items: parse_capitals(capitals.fetch(:bank_accounts, [])),
                                       non_liquid_capital_items: parse_capitals(capitals.fetch(:non_liquid_capital, [])))
      PersonData.new(details: applicant.freeze,
                     employment_details: parse_employment_details(input_params.fetch(:employment_details, [])),
                     self_employments: parse_self_employments(input_params.fetch(:self_employment_details, [])),
                     employments: parse_employment_income(input_params.fetch(:employment_income, []).presence || input_params.fetch(:employments, [])),
                     capitals_data:,
                     dependants: dependants.map(&:freeze))
    end

    def parse_capitals(capital_params)
      capital_params.map do |attrs|
        x = attrs.slice(:value, :description, :subject_matter_of_dispute)
        # convert value to a decimal just in case its a string
        y = { subject_matter_of_dispute: false }.merge(x.merge(value: x.fetch(:value).to_d))
        CapitalItem.new(**y)
      end
    end

    def parse_main_home(property_params)
      x = property_params.slice(:value, :outstanding_mortgage, :percentage_owned, :shared_with_housing_assoc, :subject_matter_of_dispute)
      y = { main_home: true }.merge(x)
      Property.new(**y)
    end

    def parse_additional_properties(property_params)
      property_params.map do |attrs|
        x = attrs.slice(:value, :outstanding_mortgage, :percentage_owned, :shared_with_housing_assoc, :subject_matter_of_dispute)
        y = { main_home: false }.merge(x)
        Property.new(**y)
      end
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
        EmploymentOrSelfEmploymentDetails.new client_reference: s[:client_reference], income: SelfEmploymentIncome.new(s.fetch(:income)).freeze
      end
    end

    def parse_employment_details(employments)
      employments.map do |s|
        EmploymentOrSelfEmploymentDetails.new client_reference: s[:client_reference],
                                              income: EmploymentIncome.new(s.fetch(:income)).freeze
      end
    end

    def parse_employment_income(employments_incomes)
      employments_incomes.map do |s|
        employment_payments = s[:payments].map do |payment|
          EmploymentPayment.new(
            date: payment[:date],
            gross_income: payment[:gross],
            benefits_in_kind: payment[:benefits_in_kind],
            tax: payment[:tax],
            national_insurance: payment[:national_insurance],
            client_id: payment[:client_id],
          )
        end
        Employment.new(
          name: s[:name],
          client_id: s[:client_id],
          receiving_only_statutory_sick_or_maternity_pay: s[:receiving_only_statutory_sick_or_maternity_pay],
          employment_payments:,
        )
      end
    end

    def validate
      validate_swagger_schema version, full_assessment_params
    end

    def full_assessment_params
      @full_assessment_params ||= JSON.parse(request.raw_post, symbolize_names: true, decimal_class: BigDecimal)
    end

    def version
      "6"
    end
  end
end
