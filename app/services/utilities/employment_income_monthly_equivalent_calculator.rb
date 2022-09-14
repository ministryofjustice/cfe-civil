module Utilities
  class EmploymentIncomeMonthlyEquivalentCalculator
    include MonthlyEquivalentCalculatable

    def self.call(employment)
      new(employment).call
    end

    def initialize(employment)
      @employment = employment
    end

    def call
      period = PaymentPeriodAnalyser.new(dates).period_pattern
      calc_method = determine_calc_method(period)
      update_payments(calc_method)
    end

  private

    def blunt_average(attribute)
      (@employment.employment_payments.sum(&attribute) / @employment.employment_payments.count).round(2)
    end

    def update_payments(calc_method)
      @employment.employment_payments.each do |payment|
        payment.update(
          gross_income_monthly_equiv: __send__(calc_method, calculation_value(calc_method, payment, :gross_income)),
          tax_monthly_equiv: __send__(calc_method, calculation_value(calc_method, payment, :tax)),
          national_insurance_monthly_equiv: __send__(calc_method, calculation_value(calc_method, payment, :national_insurance)),
        )
      end
    end

    def dates
      @employment.employment_payments.map(&:date)
    end

    def calculation_value(calc_method, payment, attribute)
      calc_method.eql?(:blunt_average) ? attribute.to_sym : payment.send(attribute)
    end
  end
end
