module Calculators
  class EmploymentMonthlyValueCalculator
    Result = Data.define(:values, :remarks)
    class << self
      def call(employment, submission_date, monthly_equivalent_payments)
        remarks_data = Calculators::TaxNiRefundCalculator.call(employment_payments: employment.employment_payments)
        values = if employment_income_variation_below_threshold?(monthly_equivalent_payments, submission_date)
                   calculate_monthly_values(monthly_equivalent_payments, calculation: :most_recent)
                 else
                   remarks_data << RemarksData.new(type: :employment_gross_income, issue: :amount_variation, ids: employment.employment_payments.map(&:client_id))
                   calculate_monthly_values(monthly_equivalent_payments, calculation: :blunt_average)
                 end
        Result.new(values:, remarks: remarks_data)
      end

      def employment_income_variation_below_threshold?(payments, submission_date)
        return false if payments.none?

        Utilities::EmploymentIncomeVariationChecker.new(payments).below_threshold?(submission_date)
      end

      def calculate_monthly_values(payments, calculation:)
        {
          monthly_gross_income: send(calculation, payments, :gross_income_monthly_equiv),
          monthly_national_insurance: send(calculation, payments, :national_insurance_monthly_equiv),
          monthly_tax: send(calculation, payments, :tax_monthly_equiv),
          monthly_benefits_in_kind: send(calculation, payments, :benefits_in_kind_monthly_equiv),
        }
      end

      def blunt_average(payments, attribute)
        values = payments.map(&attribute)
        return 0.0 if values.empty?

        (values.sum / values.size).round(2)
      end

      def most_recent(payments, attribute)
        payment = payments.max_by(&:date)
        payment.public_send(attribute)
      end
    end
  end
end
