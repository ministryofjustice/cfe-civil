module Creators
  class CashTransactionsCreator < BaseCreator
    delegate :gross_income_summary, to: :assessment

    def initialize(assessment_id:, cash_transaction_params:)
      super()
      @assessment_id = assessment_id
      @cash_transaction_params = cash_transaction_params
    end

    def call
      if json_validator.valid?
        create_records
      else
        errors.concat(json_validator.errors)
      end
      self
    end

  private

    def valid_dates
      base_date = assessment.submission_date.beginning_of_month
      @valid_dates ||= [
        base_date - 4.months,
        base_date - 3.months,
        base_date - 2.months,
        base_date - 1.month,
      ]
    end

    def create_records
      [income_attributes, outgoings_attributes].each { |categories| validate_categories(categories) }
      return unless errors.empty?

      ActiveRecord::Base.transaction do
        income_attributes.each { |category_hash| create_category(category_hash, "credit") }
        outgoings_attributes.each { |category_hash| create_category(category_hash, "debit") }
      rescue StandardError => e
        errors << "#{e.class} :: #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end

    def validate_categories(categories)
      categories.each { |category_hash| validate_category(category_hash) }
    end

    def validate_category(category_hash)
      if category_hash[:payments].size != 3
        errors << "There must be exactly 3 payments for category #{category_hash[:category]}"
        return
      end
      validate_payment_dates(category_hash)
    end

    def validate_payment_dates(category_hash)
      dates = category_hash[:payments].map { |payment| Date.parse(payment[:date]) }.sort
      return if dates == first_three_valid_dates || dates == last_three_valid_dates

      errors << "Expecting payment dates for category #{category_hash[:category]} to be 1st of three of the previous 3 months"
    end

    def first_three_valid_dates
      valid_dates.slice(0, 3)
    end

    def last_three_valid_dates
      valid_dates.slice(1, 3)
    end

    def create_category(category_hash, operation)
      cash_transaction_category = CashTransactionCategory.create!(gross_income_summary:,
                                                                  name: category_hash[:category],
                                                                  operation:)
      category_hash[:payments].each { |payment| create_cash_transaction(payment, cash_transaction_category) }
    end

    def create_cash_transaction(payment, cash_transaction_category)
      CashTransaction.create!(cash_transaction_category:,
                              date: Date.parse(payment[:date]),
                              amount: payment[:amount],
                              client_id: payment[:client_id])
    end

    def json_validator
      @json_validator ||= JsonValidator.new("cash_transaction", @cash_transaction_params)
    end

    def income_attributes
      @income_attributes ||= JSON.parse(@cash_transaction_params, symbolize_names: true)[:income]
    end

    def outgoings_attributes
      @outgoings_attributes ||= JSON.parse(@cash_transaction_params, symbolize_names: true)[:outgoings]
    end
  end
end
