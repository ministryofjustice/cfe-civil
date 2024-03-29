module Utilities
  class EmploymentIncomeMonthlyEquivalentCalculator
    MonthlyEquivPaymentData = Data.define(:gross_income_monthly_equiv,
                                          :tax_monthly_equiv,
                                          :benefits_in_kind_monthly_equiv,
                                          :national_insurance_monthly_equiv,
                                          :prisoner_levy_monthly_equiv,
                                          :student_debt_repayment_monthly_equiv,
                                          :date)
    class << self
      def call(employment_payments)
        period = PaymentPeriodAnalyser.new(dates(employment_payments)).period_pattern
        if period == :unknown
          monthly_equivalents_from_unknown_period(employment_payments)
        else
          monthly_equivalents_from_known_period(period, employment_payments)
        end
      end

    private

      def blunt_average(payments, attribute)
        (payments.sum(&attribute) / payments.count).round(2)
      end

      def monthly_equivalents_from_known_period(period, payments)
        payments.map do |payment|
          MonthlyEquivPaymentData.new(gross_income_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.gross_income),
                                      tax_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.tax),
                                      benefits_in_kind_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.benefits_in_kind),
                                      national_insurance_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.national_insurance),
                                      prisoner_levy_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.prisoner_levy),
                                      student_debt_repayment_monthly_equiv: Utilities::MonthlyAmountConverter.call(period, payment.student_debt_repayment),
                                      date: payment.date)
        end
      end

      def monthly_equivalents_from_unknown_period(payments)
        payments.map do |payment|
          MonthlyEquivPaymentData.new(gross_income_monthly_equiv: blunt_average(payments, :gross_income),
                                      tax_monthly_equiv: blunt_average(payments, :tax),
                                      benefits_in_kind_monthly_equiv: blunt_average(payments, :benefits_in_kind),
                                      national_insurance_monthly_equiv: blunt_average(payments, :national_insurance),
                                      prisoner_levy_monthly_equiv: blunt_average(payments, :prisoner_levy),
                                      student_debt_repayment_monthly_equiv: blunt_average(payments, :student_debt_repayment),
                                      date: payment.date)
        end
      end

      def dates(payments)
        payments.map(&:date)
      end
    end
  end
end
