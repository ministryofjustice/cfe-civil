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
        if params[:cash_transactions]
          CashTransactionsCreator.call(submission_date: assessment.submission_date,
                                       gross_income_summary: assessment.partner_gross_income_summary,
                                       cash_transaction_params: params[:cash_transactions])
        end
      },
    ].freeze
  end
end
