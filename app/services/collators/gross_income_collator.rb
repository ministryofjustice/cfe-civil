module Collators
  class GrossIncomeCollator
    class << self
      def call(assessment:, submission_date:, employments:, gross_income_summary:, self_employments:, employment_details:)
        employment_income_subtotals = derive_employment_income_subtotals(submission_date:, employments:, self_employments:, employment_details:)

        add_remarks(assessment:, employments:) if employments.count > 1

        perform_collation(gross_income_summary:, employment_income_subtotals:)
      end

    private

      def derive_employment_income_subtotals(submission_date:, employments:, self_employments:, employment_details:)
        employment_result = case employments.count
                            when 0
                              nil
                            when 1
                              Calculators::EmploymentIncomeCalculator.call(submission_date:,
                                                                           employment: employments.first)
                            else
                              Calculators::MultipleEmploymentsCalculator.call(submission_date:, employments:)
                            end
        self_employment_results = self_employments.map { Calculators::EmploymentIncomeCalculator.call(submission_date:, employment: _1) }
        employment_details_results = employment_details.map { Calculators::EmploymentIncomeCalculator.call(submission_date:, employment: _1) }
        EmploymentIncomeSubtotals.new(employment_result:,
                                      employment_details_results:,
                                      self_employment_results:)
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
                 categorised_bank_transactions(gross_income_summary, category)
               end

        cash_transactions = gross_income_summary.cash_transactions(:credit, category)
        cash = Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions)
        regular = Calculators::MonthlyRegularTransactionAmountCalculator.call(
          gross_income_summary.regular_transactions.with_operation_and_category(:credit, category),
        )
        GrossIncomeCategorySubtotals.new(
          category:,
          bank:,
          cash:,
          regular:,
        ).freeze
      end

      def categorised_bank_transactions(gross_income_summary, category)
        source = gross_income_summary.other_income_sources.detect { _1.name.to_sym == category }
        if source.present?
          Calculators::MonthlyEquivalentCalculator.call(collection: source.other_income_payments).tap do |monthly_income|
            # TODO: Stop persisting this
            source.update!(monthly_income:)
          end
        else
          0
        end
      end
    end
  end
end
