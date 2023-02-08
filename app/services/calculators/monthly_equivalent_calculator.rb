# examines all records in a given collection, to work out the equivalent value per calendar month

module Calculators
  class MonthlyEquivalentCalculator
    def self.call(assessment_errors:, collection:, date_method: :payment_date, amount_method: :amount)
      new.call(assessment_errors:, collection:, date_method:, amount_method:)
    end

    # examines all records in a given collection, to work out the equivalent value per calendar month
    # params:
    # * collection: The collection of records to be examined for payment dates and values
    # * date_method: The method to call on each record in the collection to retrieve the payment date
    # * amount_method: The method to call on each record in the collection to retrieve the payment amount
    #
    def call(assessment_errors:, collection:, date_method: :payment_date, amount_method: :amount)
      return 0.0 if collection.empty?

      @monthly_equivalent_calculator_collection = collection
      @monthly_equivalent_calculator_date_method = date_method
      @monthly_equivalent_calculator_amount_method = amount_method

      assessment_errors.create!(record_id: id, record_type: self.class, error_message: converter.error_message) if converter.error?
      converter.monthly_amount
    end

  private

    def dates_and_amounts
      Utilities::PaymentPeriodDataExtractor.call(collection: @monthly_equivalent_calculator_collection,
                                                 date_method: @monthly_equivalent_calculator_date_method,
                                                 amount_method: @monthly_equivalent_calculator_amount_method)
    end

    def dates
      dates_and_amounts.map(&:first)
    end

    def frequency
      @frequency ||= Utilities::PaymentPeriodAnalyser.new(dates).period_pattern
    end

    def converter
      @converter ||= Calculators::MonthlyIncomeConverter.new(frequency, payment_amounts)
    end

    def payment_amounts
      @monthly_equivalent_calculator_collection.map(&@monthly_equivalent_calculator_amount_method)
    end
  end
end
