module Creators
  class PartnerFinancialsCreator
    Result = Data.define(:errors) do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(assessment:, partner_financials_params:)
        new(assessment:, partner_financials_params:).call
      end
    end

    def initialize(assessment:, partner_financials_params:)
      @assessment = assessment
      @partner_financials_params = partner_financials_params
    end

    def call
      Assessment.transaction do
        create_records
      end
    end

  private

    attr_reader :assessment

    def create_records
      errors = CREATE_FUNCTIONS.map { |f|
        f.call(assessment, @partner_financials_params)
      }.compact.reject(&:success?).map(&:errors).reduce([], :+)

      Result.new(errors:).freeze
    rescue ActiveRecord::RecordInvalid => e
      Result.new(errors: e.record.errors.full_messages).freeze
    end

    CREATE_FUNCTIONS = [
      lambda { |assessment, _params|
        assessment.create_partner_capital_summary!
        assessment.create_partner_gross_income_summary!
        assessment.create_partner_disposable_income_summary!
        Result.new(errors: []).freeze
      },
      lambda { |assessment, params|
        irregular_income_params = params[:irregular_incomes]

        return if irregular_income_params.blank?

        IrregularIncomeCreator.call(
          irregular_income_params: { payments: irregular_income_params },
          gross_income_summary: assessment.partner_gross_income_summary,
        )
      },
      lambda { |assessment, params|
        employment_params = params[:employments]

        return if employment_params.blank?

        employments_params = { employment_income: employment_params }
        EmploymentsCreator.call(
          employments_params:,
          employment_collection: assessment.partner_employments,
        )
      },
      lambda { |assessment, params|
        regular_transaction_params = params[:regular_transactions]

        return if regular_transaction_params.blank?

        RegularTransactionsCreator.call(
          regular_transaction_params: { regular_transactions: regular_transaction_params },
          gross_income_summary: assessment.partner_gross_income_summary,
        )
      },
      lambda { |assessment, params|
        state_benefit_params = params[:state_benefits]
        return if state_benefit_params.blank?

        StateBenefitsCreator.call(
          state_benefits_params: { state_benefits: state_benefit_params },
          gross_income_summary: assessment.partner_gross_income_summary,
        )
      },
      lambda { |assessment, params|
        additional_property_params = params[:additional_properties]
        return if additional_property_params.blank?

        PartnerPropertiesCreator.call(
          capital_summary: assessment.partner_capital_summary,
          properties_params: additional_property_params,
        )
      },
      lambda { |assessment, params|
        capital_params = params[:capitals]
        return if capital_params.blank?

        CapitalsCreator.call(
          capital_params:,
          capital_summary: assessment.partner_capital_summary,
        )
      },
      lambda { |assessment, params|
        outgoings_params = params[:outgoings]
        return if outgoings_params.blank?

        OutgoingsCreator.call(
          disposable_income_summary: assessment.partner_disposable_income_summary,
          outgoings_params: { outgoings: outgoings_params },
        )
      },
      lambda { |assessment, params|
        if params[:cash_transactions]
          CashTransactionsCreator.call(submission_date: assessment.submission_date,
                                       gross_income_summary: assessment.partner_gross_income_summary,
                                       cash_transaction_params: params[:cash_transactions])
        end
      },
    ].freeze
  end
end
