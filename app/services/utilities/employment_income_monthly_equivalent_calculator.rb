module Utilities
  class EmploymentIncomeMonthlyEquivalentCalculator
    def self.call(employment)
      new(employment).call
    end

    def initialize(employment)
      @employment = employment
    end

    def call
      period = PaymentPeriodAnalyser.new(dates).period_pattern
      if period == :unknown
        monthly_equivalents_from_unknown_period
      else
        monthly_equivalents_from_known_period(period)
      end
    end

  private

    MonthlyEquivPaymentData = Data.define(:gross_income_monthly_equiv,
                                          :tax_monthly_equiv,
                                          :national_insurance_monthly_equiv,
                                          :date)

    def blunt_average(attribute)
      (@employment.employment_payments.sum(&attribute) / @employment.employment_payments.count).round(2)
    end

    def monthly_equivalents_from_known_period(period)
      @employment.employment_payments.map do |payment|
        MonthlyEquivPaymentData.new(gross_income_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.gross_income),
                                    tax_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.tax),
                                    national_insurance_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.national_insurance),
                                    date: payment.date)
      end
    end

    def monthly_equivalents_from_unknown_period
      @employment.employment_payments.map do |payment|
        MonthlyEquivPaymentData.new(gross_income_monthly_equiv: blunt_average(:gross_income),
                                    tax_monthly_equiv: blunt_average(:tax),
                                    national_insurance_monthly_equiv: blunt_average(:national_insurance),
                                    date: payment.date)
      end
    end

    def dates
      @employment.employment_payments.map(&:date)
    end
  end
end
