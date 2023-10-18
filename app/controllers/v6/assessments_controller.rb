module V6
  class AssessmentsController < ApplicationController
    before_action :validate

    EmploymentOrSelfEmploymentDetails = Data.define(:income, :client_reference)

    def create
      create = Creators::FullAssessmentCreator.call(remote_ip: request.remote_ip,
                                                    params: full_assessment_params)
      if create.success?
        # populate_eligibility_records
        Utilities::ProceedingTypeThresholdPopulator.call(create.assessment)

        applicant_dependants = dependants full_assessment_params, create.assessment.submission_date
        render_unprocessable(dependant_errors(applicant_dependants)) && return if applicant_dependants.reject(&:valid?).any?

        applicant_model = Applicant.new(full_assessment_params.fetch(:applicant, {}))
        render_unprocessable(applicant_model.errors.full_messages) && return unless applicant_model.valid?

        applicant_outgoings = parse_outgoings(full_assessment_params.fetch(:outgoings, []))
        render_unprocessable(dependant_errors(applicant_outgoings)) && return if applicant_outgoings.reject(&:valid?).any?

        applicant = person_data(full_assessment_params,
                                applicant_dependants,
                                applicant_model,
                                full_assessment_params.fetch(:properties, {})[:main_home],
                                full_assessment_params.fetch(:properties, {}).fetch(:additional_properties, []),
                                applicant_outgoings)

        partner_params = full_assessment_params[:partner]
        if partner_params.present?
          partner_dependants = dependants partner_params, create.assessment.submission_date
          render_unprocessable(dependant_errors(partner_dependants)) && return if partner_dependants.reject(&:valid?).any?

          partner_model = Applicant.new(partner_params.fetch(:partner, {}))
          render_unprocessable(partner_model.errors.full_messages) && return unless partner_model.valid?

          partner_outgoings = parse_outgoings(partner_params.fetch(:outgoings, []))
          render_unprocessable(dependant_errors(partner_outgoings)) && return if partner_outgoings.reject(&:valid?).any?

          partner = person_data(partner_params,
                                partner_dependants,
                                partner_model,
                                nil,
                                partner_params.fetch(:additional_properties, []),
                                partner_outgoings)

          calculation_output = Workflows::MainWorkflow.call(assessment: create.assessment,
                                                            applicant:,
                                                            partner:)
          add_remarks(assessment: create.assessment, applicant:, partner:, calculation_output:)
        else
          calculation_output = Workflows::MainWorkflow.call(assessment: create.assessment,
                                                            applicant:,
                                                            partner: nil)
          add_remarks(assessment: create.assessment, applicant:, partner: nil, calculation_output:)
        end
        render json: assessment_decorator_class.new(assessment: create.assessment, calculation_output:, applicant:, partner:, version:).as_json
      else
        render_unprocessable(create.errors)
      end
    end

  private

    def add_remarks(assessment:, applicant:, partner:, calculation_output:)
      # we can take the lower threshold from the first eligibility records as they are all the same
      # lower_capital_threshold = assessment.applicant_capital_summary.eligibilities.first.lower_threshold
      lower_capital_threshold = calculation_output.capital_subtotals.eligibilities.first.lower_threshold

      new_remarks = RemarkGenerators::Orchestrator.call(employments: applicant.employments,
                                                        gross_income_summary: assessment.applicant_gross_income_summary,
                                                        outgoings: applicant.outgoings,
                                                        liquid_capital_items: applicant.capitals_data.liquid_capital_items,
                                                        state_benefits: applicant.state_benefits,
                                                        lower_capital_threshold:,
                                                        child_care_bank: calculation_output.applicant_disposable_income_subtotals.child_care_bank,
                                                        assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
      if partner.present?
        new_remarks += RemarkGenerators::Orchestrator.call(employments: partner.employments,
                                                           gross_income_summary: assessment.partner_gross_income_summary,
                                                           outgoings: partner.outgoings,
                                                           liquid_capital_items: partner.capitals_data.liquid_capital_items,
                                                           lower_capital_threshold:,
                                                           state_benefits: partner.state_benefits,
                                                           child_care_bank: calculation_output.partner_disposable_income_subtotals.child_care_bank,
                                                           assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
      end
      assessment.add_remarks!(new_remarks)
    end

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

    def person_data(input_params, dependants, applicant, main_home, additional_properties, outgoings)
      capitals = input_params.fetch(:capitals, {})
      capitals_data = CapitalsData.new(vehicles: parse_vehicles(input_params.fetch(:vehicles, [])),
                                       main_home: main_home.present? ? parse_main_home(main_home) : nil,
                                       additional_properties: parse_additional_properties(additional_properties),
                                       liquid_capital_items: parse_capitals(capitals.fetch(:bank_accounts, [])),
                                       non_liquid_capital_items: parse_capitals(capitals.fetch(:non_liquid_capital, [])))

      employments = input_params.fetch(:employment_income, []).presence || input_params.fetch(:employments, [])
      PersonData.new(details: applicant.freeze,
                     employment_details: parse_employment_details(input_params.fetch(:employment_details, [])),
                     self_employments: parse_self_employments(input_params.fetch(:self_employment_details, [])),
                     employments: parse_employment_income(employments),
                     capitals_data:,
                     outgoings:,
                     dependants: dependants.map(&:freeze),
                     state_benefits: parse_state_benefits(input_params.fetch(:state_benefits, [])))
    end

    def parse_state_benefits(state_benefits_params)
      state_benefits_params.map do |p|
        payments = p[:payments].map do |payment|
          StateBenefitPayment.new(
            payment_date: payment[:date],
            amount: payment[:amount],
            client_id: payment[:client_id],
            flags: generate_flags(payment),
          )
        end
        benefit_type = StateBenefitType.find_by(label: p[:name]) || StateBenefitType.find_by(label: "other")
        StateBenefit.new(state_benefit_payments: payments,
                         state_benefit_name: p[:name],
                         exclude_from_gross_income: benefit_type.exclude_from_gross_income)
      end
    end

    def generate_flags(hash)
      return false if hash[:flags].blank?

      hash[:flags].map { |k, v| k if v.eql?(true) }.compact
    end

    def parse_outgoings(outgoings_params)
      outgoings_params.map { |outgoing|
        klass = CFEConstants::OUTGOING_KLASSES[outgoing[:name].to_sym]
        outgoing[:payments].map do |payment_params|
          klass.new payment_params
        end
      }.flatten
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

    def parse_employment_income(employments)
      employments.map do |employment|
        employment_payments = employment[:payments].map do |payment|
          EmploymentPayment.new(
            date: Date.parse(payment[:date]),
            gross_income: payment[:gross],
            benefits_in_kind: payment[:benefits_in_kind],
            tax: payment[:tax],
            national_insurance: payment[:national_insurance],
            prisoner_levy: payment.fetch(:prisoner_levy, 0.0),
            student_debt_repayment: payment.fetch(:student_debt_repayment, 0.0),
            client_id: payment[:client_id],
          ).freeze
        end
        Employment.new(
          name: employment[:name],
          client_id: employment[:client_id],
          receiving_only_statutory_sick_or_maternity_pay: employment[:receiving_only_statutory_sick_or_maternity_pay],
          employment_payments:,
        ).freeze
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
