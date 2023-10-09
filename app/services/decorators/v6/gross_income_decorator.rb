module Decorators
  module V6
    class GrossIncomeDecorator
      def initialize(summary, employments, subtotals)
        @summary = summary
        @employments = employments
        @subtotals = subtotals
      end

      def as_json
        {
          employment_income: employment_incomes,
          irregular_income:,
          state_benefits:,
          other_income:,
        }.tap do |result|
          self_employments = employment_income_subtotals.self_employment_details
          employments = employment_income_subtotals.employment_details
          result[:self_employment_details] = employment_details(self_employments) if self_employments.any?
          result.merge!(employment_details: employment_details(employments)) if employments.any?
        end
      end

    private

      attr_reader :summary

      def employment_incomes
        employment_income_subtotals.payment_based_employments.sort_by(&:employment_name).map do |job|
          {
            name: job.employment_name,
            payments: job.employment_payments.sort_by(&:date).reverse.map { |p| employment_payment(p) },
          }
        end
      end

      def employment_income_subtotals
        @subtotals.employment_income_subtotals
      end

      def employment_details(employments)
        employments.map do |details|
          {
            monthly_income: {
              gross: details.monthly_gross_income,
              tax: details.monthly_tax,
              national_insurance: details.monthly_national_insurance,
              prisoner_levy: details.monthly_prisoner_levy,
              benefits_in_kind: details.monthly_benefits_in_kind,
            },
          }.tap do |result|
            result.merge!(client_reference: details.client_id) if details.client_id
          end
        end
      end

      def employment_payment(payment)
        {
          date: payment.date.strftime("%Y-%m-%d"),
          gross: payment.gross_income.to_f,
          benefits_in_kind: payment.benefits_in_kind.to_f,
          tax: payment.tax.to_f,
          national_insurance: payment.national_insurance.to_f,
          prisoner_levy: payment.prisoner_levy.to_f,
          net_employment_income: net_employment_income(payment).to_f,
        }
      end

      def net_employment_income(payment)
        payment.gross_income + payment.benefits_in_kind + payment.tax + payment.national_insurance + payment.prisoner_levy
      end

      def irregular_income
        {
          monthly_equivalents:
            {
              student_loan: @subtotals.monthly_student_loan.to_f,
              unspecified_source: @subtotals.monthly_unspecified_source.to_f,
            },
        }
      end

      def other_income
        {
          monthly_equivalents: {
            all_sources: transactions(:all_sources),
            bank_transactions: transactions(:bank),
            cash_transactions: transactions(:cash),
          },
        }
      end

      def transactions(source)
        {
          friends_or_family: @subtotals.monthly_regular_incomes(source, :friends_or_family),
          maintenance_in: @subtotals.monthly_regular_incomes(source, :maintenance_in),
          property_or_lodger: @subtotals.monthly_regular_incomes(source, :property_or_lodger),
          pension: @subtotals.monthly_regular_incomes(source, :pension),
        }
      end

      def state_benefits
        {
          monthly_equivalents: {
            all_sources: @subtotals.monthly_regular_incomes(:all_sources, :benefits).to_f,
            cash_transactions: @subtotals.monthly_regular_incomes(:cash, :benefits),
            bank_transactions: @subtotals.state_benefits.map { |sb| StateBenefitDecorator.new(sb).as_json },
          },
        }
      end
    end
  end
end
