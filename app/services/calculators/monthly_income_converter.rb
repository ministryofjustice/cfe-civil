module Calculators
  class MonthlyIncomeConverter
    def initialize(frequency, payments)
      @frequency = frequency
      @payments = payments
      @error = false
      @error_message = nil
      @monthly_amount = nil
    end

    def monthly_amount
      raise "Unrecognized frequency" unless @frequency.in?(CFEConstants::VALID_FREQUENCIES)

      __send__("process_#{@frequency}")
    end

  private

    def process_monthly
      payment_average.round(2)
    end

    def process_four_weekly
      ((payment_average / 4) * 52 / 12).round(2)
    end

    def process_two_weekly
      ((payment_average / 2) * 52 / 12).round(2)
    end

    def process_weekly
      (payment_average * 52 / 12).round(2)
    end

    def process_unknown
      (@payments.sum.to_d / CFEConstants::NUMBER_OF_MONTHS_TO_AVERAGE).round(2)
    end

    def payment_average
      @payments.sum.to_d / @payments.size
    end
  end
end
