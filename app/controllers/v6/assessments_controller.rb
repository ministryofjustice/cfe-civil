module V6
  class AssessmentsController < ApplicationController
    before_action :validate

    EmploymentOrSelfEmploymentDetails = Data.define(:income, :client_reference)

    def create
      create = Creators::FullAssessmentCreator.call(remote_ip: request.remote_ip,
                                                    params: full_assessment_params)
      if create.success?
        Utilities::ProceedingTypeThresholdPopulator.call(create.assessment)

        applicant = person_data(input_params: full_assessment_params,
                                model_params: full_assessment_params.fetch(:applicant, {}),
                                irregular_income_params: full_assessment_params.fetch(:irregular_incomes, {}),
                                additional_properties_params: full_assessment_params.fetch(:properties, {}),
                                main_home_params: full_assessment_params.fetch(:properties, {})[:main_home],
                                submission_date: create.assessment.submission_date) || return

        partner_params = full_assessment_params[:partner]
        full = if partner_params.present?
                 partner = person_data(input_params: partner_params,
                                       model_params: partner_params.fetch(:partner, {}),
                                       irregular_income_params: { payments: partner_params.fetch(:irregular_incomes, []) },
                                       submission_date: create.assessment.submission_date,
                                       main_home_params: nil,
                                       additional_properties_params: partner_params) || return
                 Workflows::PersonWorkflow.with_partner_workflow(assessment: create.assessment, applicant:, partner:)
               else
                 Workflows::PersonWorkflow.without_partner_workflow(assessment: create.assessment, applicant:)
               end

        render json: assessment_decorator_class.new(assessment: create.assessment,
                                                    calculation_output: full.workflow_result.calculation_output,
                                                    applicant:, partner:, version:, eligibility_result: full.eligibility_result, remarks: full.workflow_result.remarks).as_json
      else
        render_unprocessable(create.errors)
      end
    end

  private

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

    def person_data(input_params:, submission_date:, model_params:, main_home_params:, additional_properties_params:,
                    irregular_income_params:)
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

      cash_transaction_params = input_params.fetch(:cash_transactions, {})
      cash_transactions = Creators::CashTransactionsCreator.call(cash_transaction_params:, submission_date:)
      render_unprocessable(cash_transactions.errors) && return if cash_transactions.errors.any?

      PersonData.new(details: person_model.freeze,
                     employment_details: parse_employment_details(input_params.fetch(:employment_details, [])),
                     self_employments: parse_self_employments(input_params.fetch(:self_employment_details, [])),
                     employments: parse_employment_income(employments),
                     capitals_data:,
                     outgoings:,
                     other_income_payments:,
                     irregular_income_payments: parse_irregular_incomes(irregular_income_params).map(&:freeze),
                     cash_transactions: cash_transactions.records,
                     regular_transactions: parse_regular_transactions(input_params.fetch(:regular_transactions, [])),
                     dependants: dependant_models.map(&:freeze),
                     state_benefits: parse_state_benefits(input_params.fetch(:state_benefits, [])))
    end

    def parse_regular_transactions(regular_transaction_params)
      regular_transaction_params.map do |regular_transaction|
        RegularTransaction.new category: regular_transaction[:category].to_sym, operation: regular_transaction[:operation].to_sym,
                               frequency: regular_transaction[:frequency].to_sym, amount: regular_transaction[:amount]
      end
    end

    def parse_irregular_incomes(irregular_income_params)
      irregular_income_params.fetch(:payments, []).map do |payment_params|
        IrregularIncomePayment.new(
          income_type: payment_params[:income_type].to_sym,
          frequency: payment_params[:frequency],
          amount: payment_params[:amount],
        )
      end
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
