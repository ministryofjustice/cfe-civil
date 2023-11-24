module Creators
  class CashTransactionsCreator
    Result = Data.define :errors, :records

    class << self
      def call(submission_date:, cash_transaction_params:)
        create_records submission_date:, cash_transaction_params:
      end

    private

      def valid_dates(submission_date)
        base_date = submission_date.beginning_of_month
        [
          base_date - 4.months,
          base_date - 3.months,
          base_date - 2.months,
          base_date - 1.month,
        ]
      end

      def create_records(submission_date:, cash_transaction_params:)
        incomes = income_attributes(cash_transaction_params).map { |category_hash| create_category(category_hash:, operation: :credit) }.reduce({}) { _1.merge(_2) }
        outgoings = outgoings_attributes(cash_transaction_params).map { |category_hash| create_category(category_hash:, operation: :debit) }.reduce({}) { _1.merge(_2) }

        records_hash = incomes.merge(outgoings)

        errors = records_hash.map { |category, cash_transactions| validate_category(category:, cash_transactions:, submission_date:) }.compact
        Result.new(errors:, records: records_hash.values.reduce([], &:+))
      end

      def validate_category(category:, cash_transactions:, submission_date:)
        if cash_transactions.size != 3
          return "There must be exactly 3 payments for category #{category}"
        end

        validate_payment_dates(category:, cash_transactions:, submission_date:)
      end

      def validate_payment_dates(category:, cash_transactions:, submission_date:)
        dates = cash_transactions.map(&:date).compact.sort
        return if dates == first_three_valid_dates(submission_date) || dates == last_three_valid_dates(submission_date)

        "Expecting payment dates for category #{category} to be 1st of three of the previous 3 months"
      end

      def first_three_valid_dates(submission_date)
        valid_dates(submission_date).slice(0, 3)
      end

      def last_three_valid_dates(submission_date)
        valid_dates(submission_date).slice(1, 3)
      end

      #  return a hash key
      def create_category(category_hash:, operation:)
        cash_transactions = category_hash[:payments].map { |payment| create_cash_transaction(category: category_hash[:category], operation:, payment:) }
        { category_hash[:category] => cash_transactions }
      end

      def create_cash_transaction(category:, operation:, payment:)
        CashTransaction.new(
          category: category.to_sym,
          operation:,
          date: safe_date_parse(payment[:date]),
          amount: payment[:amount],
          client_id: payment[:client_id],
        )
      end

      # emulate rails date parsing, convert to nil if not a valid date
      def safe_date_parse(value)
        Date.parse(value)
      rescue StandardError
        nil
      end

      def income_attributes(cash_transaction_params)
        cash_transaction_params.fetch(:income, [])
      end

      def outgoings_attributes(cash_transaction_params)
        cash_transaction_params.fetch(:outgoings, [])
      end
    end
  end
end
