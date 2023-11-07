module Collators
  class GrossIncomeCollator
    Result = Data.define(:remarks, :person_gross_income_subtotals)

    class << self
      def call(submission_date:, employments:, gross_income_summary:, self_employments:, employment_details:, state_benefits:)
        employment_income_subtotals = derive_employment_income_subtotals(submission_date:, employments:, self_employments:, employment_details:)

        remarks = if employments.count > 1
                    [RemarksData.new(type: :employment, issue: :multiple_employments, ids: employments.map(&:client_id))]
                  else
                    []
                  end

        regular_income_categories = income_categories.map do |category|
          if category == :benefits
            benefits_category_subtotals(gross_income_summary:, submission_date:, state_benefits:)
          else
            calculate_category_subtotals(category:, gross_income_summary:)
          end
        end

        person_gross_income_subtotals = PersonGrossIncomeSubtotals.new(
          student_loan_payments: gross_income_summary.student_loan_payments,
          unspecified_source_payments: gross_income_summary.unspecified_source_payments,
          regular_income_categories:,
          employment_income_subtotals:,
          state_benefits:,
        )

        Result.new(person_gross_income_subtotals:, remarks:)
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

      def income_categories
        CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)
      end

      def benefits_category_subtotals(gross_income_summary:, submission_date:, state_benefits:)
        state_benefits_calculations = Calculators::StateBenefitsCalculator.benefits(regular_transactions: gross_income_summary.regular_transactions,
                                                                                    submission_date:, state_benefits:)
        GrossIncomeCategorySubtotals.new(
          category: :benefits,
          bank: state_benefits_calculations.state_benefits_bank,
          cash: cash_transactions_for_category(gross_income_summary, :benefits),
          regular: state_benefits_calculations.state_benefits_regular,
        )
      end

      def calculate_category_subtotals(category:, gross_income_summary:)
        GrossIncomeCategorySubtotals.new(
          category:,
          bank: categorised_bank_transactions(gross_income_summary, category),
          cash: cash_transactions_for_category(gross_income_summary, category),
          regular: Calculators::MonthlyRegularTransactionAmountCalculator.call(
            gross_income_summary.regular_transactions.with_operation_and_category(:credit, category),
          ),
        )
      end

      def cash_transactions_for_category(gross_income_summary, category)
        cash_transactions = gross_income_summary.cash_transactions.by_operation_and_category(:credit, category)
        Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions)
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
