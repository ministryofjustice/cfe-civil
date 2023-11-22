module V6
  class AssessmentsController < ApplicationController
    before_action :validate

    EmploymentOrSelfEmploymentDetails = Data.define(:income, :client_reference)

    ResultAndEligibility = Data.define(:workflow_result, :eligibility_result)

    def create
      create = Creators::FullAssessmentCreator.call(remote_ip: request.remote_ip,
                                                    params: full_assessment_params)
      if create.success?
        Utilities::ProceedingTypeThresholdPopulator.call(create.assessment)

        applicant = person_data(input_params: full_assessment_params,
                                model_params: full_assessment_params.fetch(:applicant, {}),
                                additional_properties_params: full_assessment_params.fetch(:properties, {}),
                                main_home_params: full_assessment_params.fetch(:properties, {})[:main_home],
                                gross_income_summary: create.assessment.applicant_gross_income_summary,
                                submission_date: create.assessment.submission_date) || return

        partner_params = full_assessment_params[:partner]
        full = if partner_params.present?
                 partner = person_data(input_params: partner_params,
                                       model_params: partner_params.fetch(:partner, {}),
                                       submission_date: create.assessment.submission_date,
                                       main_home_params: nil,
                                       additional_properties_params: partner_params,
                                       gross_income_summary: create.assessment.partner_gross_income_summary) || return
                 with_partner_workflow(assessment: create.assessment, applicant:, partner:)
               else
                 without_partner_workflow(assessment: create.assessment, applicant:)
               end

        render json: assessment_decorator_class.new(assessment: create.assessment,
                                                    calculation_output: full.workflow_result.calculation_output,
                                                    applicant:, partner:, version:, eligibility_result: full.eligibility_result, remarks: full.workflow_result.remarks).as_json
      else
        render_unprocessable(create.errors)
      end
    end

  private

    def without_partner_workflow(assessment:, applicant:)
      result = Workflows::MainWorkflow.without_partner(submission_date: assessment.submission_date, level_of_help: assessment.level_of_help,
                                                       proceeding_types: assessment.proceeding_types,
                                                       applicant:)
      lower_capital_threshold = result.calculation_output.lower_capital_threshold(assessment.proceeding_types)
      assessed_capital = result.calculation_output.combined_assessed_capital

      new_remarks = RemarkGenerators::Orchestrator.call(employments: applicant.employments,
                                                        other_income_payments: applicant.other_income_payments,
                                                        cash_transactions: assessment.applicant_gross_income_summary.cash_transactions,
                                                        regular_transactions: assessment.applicant_gross_income_summary.regular_transactions,
                                                        submission_date: assessment.submission_date,
                                                        outgoings: applicant.outgoings,
                                                        liquid_capital_items: applicant.capitals_data.liquid_capital_items,
                                                        state_benefits: applicant.state_benefits,
                                                        lower_capital_threshold:,
                                                        child_care_bank: result.calculation_output.applicant_disposable_income_subtotals.child_care_bank,
                                                        assessed_capital:)
      workflow = Workflows::MainWorkflow::Result.new calculation_output: result.calculation_output,
                                                     remarks: new_remarks + result.remarks,
                                                     assessment_result: result.assessment_result
      er = EligibilityResults.without_partner(
        proceeding_types: assessment.proceeding_types,
        submission_date: assessment.submission_date,
        applicant:,
        level_of_help: assessment.level_of_help,
      )
      ResultAndEligibility.new workflow_result: workflow, eligibility_result: er
    end

    def with_partner_workflow(assessment:, applicant:, partner:)
      part = Workflows::MainWorkflow.with_partner(submission_date: assessment.submission_date,
                                                  level_of_help: assessment.level_of_help,
                                                  proceeding_types: assessment.proceeding_types,
                                                  applicant:,
                                                  partner:)
      lower_capital_threshold = part.calculation_output.lower_capital_threshold(assessment.proceeding_types)
      assessed_capital = part.calculation_output.combined_assessed_capital

      remarks = RemarkGenerators::Orchestrator.call(employments: applicant.employments,
                                                    other_income_payments: applicant.other_income_payments,
                                                    cash_transactions: assessment.applicant_gross_income_summary.cash_transactions,
                                                    regular_transactions: assessment.applicant_gross_income_summary.regular_transactions,
                                                    submission_date: assessment.submission_date,
                                                    outgoings: applicant.outgoings,
                                                    liquid_capital_items: applicant.capitals_data.liquid_capital_items,
                                                    state_benefits: applicant.state_benefits,
                                                    lower_capital_threshold:,
                                                    child_care_bank: part.calculation_output.applicant_disposable_income_subtotals.child_care_bank,
                                                    assessed_capital:)
      remarks += RemarkGenerators::Orchestrator.call(employments: partner.employments,
                                                     other_income_payments: partner.other_income_payments,
                                                     cash_transactions: assessment.partner_gross_income_summary.cash_transactions,
                                                     regular_transactions: assessment.partner_gross_income_summary.regular_transactions,
                                                     submission_date: assessment.submission_date,
                                                     outgoings: partner.outgoings,
                                                     liquid_capital_items: partner.capitals_data.liquid_capital_items,
                                                     lower_capital_threshold:,
                                                     state_benefits: partner.state_benefits,
                                                     child_care_bank: part.calculation_output.partner_disposable_income_subtotals.child_care_bank,
                                                     assessed_capital:)
      workflow_result = Workflows::MainWorkflow::Result.new calculation_output: part.calculation_output,
                                                            assessment_result: part.assessment_result,
                                                            remarks: remarks + part.remarks
      er = EligibilityResults.with_partner(
        proceeding_types: assessment.proceeding_types,
        submission_date: assessment.submission_date,
        applicant:,
        level_of_help: assessment.level_of_help,
        partner:,
      )
      ResultAndEligibility.new workflow_result:, eligibility_result: er
    end

    def assessment_decorator_class
      Decorators::V6::AssessmentDecorator
    end

    def parse_dependants(input_params, submission_date)
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

    def person_data(input_params:, submission_date:, model_params:, main_home_params:, additional_properties_params:, gross_income_summary:)
      dependant_models = parse_dependants input_params, submission_date
      render_unprocessable(dependant_errors(dependant_models)) && return if dependant_models.reject(&:valid?).any?

      person_model = Applicant.new(model_params)
      render_unprocessable(person_model.errors.full_messages) && return unless person_model.valid?

      outgoings = parse_outgoings(input_params.fetch(:outgoings, []))
      render_unprocessable(dependant_errors(outgoings)) && return if outgoings.reject(&:valid?).any?

      other_income_payments = parse_other_incomes(input_params.fetch(:other_incomes, []))

      additional_properties = additional_properties_params.fetch(:additional_properties, [])

      capitals = input_params.fetch(:capitals, {})
      capitals_data = CapitalsData.new(vehicles: parse_vehicles(input_params.fetch(:vehicles, [])),
                                       main_home: main_home_params.present? ? parse_main_home(main_home_params) : nil,
                                       additional_properties: parse_additional_properties(additional_properties),
                                       liquid_capital_items: parse_capitals(capitals.fetch(:bank_accounts, [])),
                                       non_liquid_capital_items: parse_capitals(capitals.fetch(:non_liquid_capital, [])))

      employments = input_params.fetch(:employment_income, []).presence || input_params.fetch(:employments, [])
      PersonData.new(details: person_model.freeze,
                     employment_details: parse_employment_details(input_params.fetch(:employment_details, [])),
                     self_employments: parse_self_employments(input_params.fetch(:self_employment_details, [])),
                     employments: parse_employment_income(employments),
                     capitals_data:,
                     outgoings:,
                     other_income_payments:,
                     gross_income_summary:,
                     dependants: dependant_models.map(&:freeze),
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

    def parse_other_incomes(other_incomes_params)
      other_incomes_params.map { |other_income|
        other_income[:payments].map do |payment_params|
          OtherIncomePayment.new(category: other_income[:source].to_sym,
                                 payment_date: Date.parse(payment_params[:date]),
                                 amount: payment_params[:amount],
                                 client_id: payment_params[:client_id])
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
