# examines all records in a given collection, to work out the equivalent value per calendar month

module Calculators
  class MonthlyEquivalentCalculator
    class << self
      # examines all records in a given collection, to work out the equivalent value per calendar month
      # params:
      # * collection: The collection of records to be examined for payment dates and values
      # * date_method: The method to call on each record in the collection to retrieve the payment date
      # * amount_method: The method to call on each record in the collection to retrieve the payment amount
      #
      def call(collection:, date_method: :payment_date, amount_method: :amount)
        if collection.empty?
          0.0
        else
          dates = collection.map { _1.__send__(date_method) }
          frequency = Utilities::PaymentPeriodAnalyser.new(dates).period_pattern
          Calculators::MonthlyIncomeConverter.new(
            frequency,
            collection.map(&amount_method),
          ).monthly_amount
        end
      end
    end
  end
end
