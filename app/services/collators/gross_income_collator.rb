module Collators
  class GrossIncomeCollator
    class << self
      def call(assessment:, submission_date:, employments:, gross_income_summary:)
        employment_income_subtotals = derive_employment_income_subtotals(assessment:, submission_date:, employments:)
        perform_collation(gross_income_summary:, employment_income_subtotals:)
      end

    private

      def derive_employment_income_subtotals(assessment:, submission_date:, employments:)
        calculate_subtotals(submission_date:, employments:).tap do
          add_remarks(assessment:, employments:) if employments.count > 1
        end
      end

      def calculate_subtotals(submission_date:, employments:)
        case employments.count
        when 0
          EmploymentIncomeSubtotals.blank
        when 1
          Calculators::EmploymentIncomeCalculator.call(submission_date:,
                                                       employment: employments.first)
        else
          Calculators::MultipleEmploymentsCalculator.call(submission_date)
        end
      end

      def add_remarks(assessment:, employments:)
        my_remarks = assessment.remarks
        my_remarks.add(:employment, :multiple_employments, employments.map(&:client_id))
        assessment.update!(remarks: my_remarks)
      end

      def income_categories
        CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)
      end

      def perform_collation(gross_income_summary:, employment_income_subtotals:)
        regular_income_categories = income_categories.map do |category|
          calculate_category_subtotals(category, gross_income_summary)
        end

        PersonGrossIncomeSubtotals.new(
          gross_income_summary:,
          regular_income_categories:,
          employment_income_subtotals:,
        )
      end

      def calculate_category_subtotals(category, gross_income_summary)
        bank = if category == :benefits
                 Calculators::StateBenefitsCalculator.call(gross_income_summary.state_benefits)
               else
                 categorised_bank_transactions(gross_income_summary)[category]
               end

        cash = Calculators::MonthlyCashTransactionAmountCalculator.call(gross_income_summary:, operation: :credit, category:)
        regular = Calculators::MonthlyRegularTransactionAmountCalculator.call(gross_income_summary:, operation: :credit, category:)
        GrossIncomeCategorySubtotals.new(
          category:,
          bank:,
          cash:,
          regular:,
        ).freeze
      end

      def categorised_bank_transactions(gross_income_summary)
        result = Hash.new(0.0)
        gross_income_summary.other_income_sources.each do |source|
          monthly_income = Calculators::MonthlyEquivalentCalculator.call(
            collection: source.other_income_payments,
          )

          # TODO: Stop persisting this
          source.update!(monthly_income:)

          formatted = BigDecimal(monthly_income, Float::DIG)
          result[source.name.to_sym] = formatted
        end

        result
      end
    end
  end
end
