module Creators
  class CashTransactionsCreator
    Result = Struct.new :errors, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(submission_date:, gross_income_summary:, cash_transaction_params:)
        new(submission_date:, gross_income_summary:, cash_transaction_params:).call
      end
    end

    def initialize(submission_date:, gross_income_summary:, cash_transaction_params:)
      @submission_date = submission_date
      @gross_income_summary = gross_income_summary
      @cash_transaction_params = cash_transaction_params
    end

    def call
      create_records
    end

  private

    def valid_dates
      base_date = @submission_date.beginning_of_month
      @valid_dates ||= [
        base_date - 4.months,
        base_date - 3.months,
        base_date - 2.months,
        base_date - 1.month,
      ]
    end

    def create_records
      errors = ActiveRecord::Base.transaction do
        incomes = income_attributes.map { |category_hash| create_category(category_hash, "credit") }
        outgoings = outgoings_attributes.map { |category_hash| create_category(category_hash, "debit") }

        (incomes + outgoings).map { |categories| validate_category(categories) }.compact.tap do |validation_errors|
          if validation_errors.empty?
            (incomes + outgoings).each(&:save!)
          end
        end
      end
      Result.new(errors:)
    end

    def validate_category(cash_transaction_category)
      if cash_transaction_category.cash_transactions.size != 3
        return "There must be exactly 3 payments for category #{cash_transaction_category.name}"
      end

      validate_payment_dates(cash_transaction_category)
    end

    def validate_payment_dates(cash_transaction_category)
      dates = cash_transaction_category.cash_transactions.map(&:date).compact.sort
      return if dates == first_three_valid_dates || dates == last_three_valid_dates

      "Expecting payment dates for category #{cash_transaction_category.name} to be 1st of three of the previous 3 months"
    end

    def first_three_valid_dates
      valid_dates.slice(0, 3)
    end

    def last_three_valid_dates
      valid_dates.slice(1, 3)
    end

    def create_category(category_hash, operation)
      @gross_income_summary.cash_transaction_categories.build(name: category_hash[:category], operation:).tap do |cash_transaction_category|
        category_hash[:payments].each { |payment| create_cash_transaction(payment, cash_transaction_category) }
      end
    end

    def create_cash_transaction(payment, cash_transaction_category)
      cash_transaction_category.cash_transactions.build(
        date: payment[:date],
        amount: payment[:amount],
        client_id: payment[:client_id],
      )
    end

    def income_attributes
      @income_attributes ||= @cash_transaction_params[:income]
    end

    def outgoings_attributes
      @outgoings_attributes ||= @cash_transaction_params[:outgoings]
    end
  end
end
