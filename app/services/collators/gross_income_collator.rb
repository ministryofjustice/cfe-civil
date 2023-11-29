module Collators
  class GrossIncomeCollator
    Result = Data.define(:remarks, :person_gross_income_subtotals)

    class << self
      def call(submission_date:, employments:, self_employments:, employment_details:, state_benefits:,
               regular_transactions:, cash_transactions:, other_income_payments:, irregular_income_payments:)
        employment_income_subtotals = derive_employment_income_subtotals(submission_date:, employments:, self_employments:, employment_details:)

        remarks = if employments.count > 1
                    [RemarksData.new(type: :employment, issue: :multiple_employments, ids: employments.map(&:client_id))]
                  else
                    []
                  end

        # It's useful to call this here to avoid confusion with filtering (which is done by StateBenefitsCalculator#benefits)
        # being done at different levels in the code
        state_benefit_results = Calculators::StateBenefitsCalculator.benefits(regular_transactions:,
                                                                              submission_date:, state_benefits:)

        regular_income_categories = [
          benefits_category_subtotals(cash_transactions: cash_transactions.select(&:benefits?),
                                      state_benefits_bank: state_benefit_results.state_benefits_bank,
                                      state_benefits_regular: state_benefit_results.state_benefits_regular),
          calculate_category_subtotals(category: :friends_or_family, other_income_payments:, regular: friends_or_family_regular(regular_transactions), cash_transactions: cash_transactions.select(&:friends_or_family?)),
          calculate_category_subtotals(category: :maintenance_in, other_income_payments:, regular: maintenance_in_regular(regular_transactions), cash_transactions: cash_transactions.select(&:maintenance_in?)),
          calculate_category_subtotals(category: :property_or_lodger, other_income_payments:, regular: property_or_lodger_regular(regular_transactions), cash_transactions: cash_transactions.select(&:property_or_lodger?)),
          calculate_category_subtotals(category: :pension, other_income_payments:, regular: pension_regular(regular_transactions), cash_transactions: cash_transactions.select(&:pension?)),
        ]

        person_gross_income_subtotals = PersonGrossIncomeSubtotals.new(
          irregular_income_payments:,
          regular_income_categories:,
          employment_income_subtotals:,
          state_benefits:,
        )

        Result.new(person_gross_income_subtotals:, remarks:)
      end

    private

      def friends_or_family_regular(regular_transactions)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(regular_transactions.select(&:friends_or_family?))
      end

      def maintenance_in_regular(regular_transactions)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(regular_transactions.select(&:maintenance_in?))
      end

      def property_or_lodger_regular(regular_transactions)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(regular_transactions.select(&:property_or_lodger?))
      end

      def pension_regular(regular_transactions)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(regular_transactions.select(&:pension?))
      end

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

      def benefits_category_subtotals(cash_transactions:, state_benefits_bank:, state_benefits_regular:)
        GrossIncomeCategorySubtotals.new(
          category: :benefits,
          bank: state_benefits_bank,
          cash: Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions),
          regular: state_benefits_regular,
        )
      end

      def calculate_category_subtotals(category:, regular:, cash_transactions:, other_income_payments:)
        GrossIncomeCategorySubtotals.new(
          category:,
          bank: categorised_bank_transactions(other_income_payments, category),
          cash: Calculators::MonthlyCashTransactionAmountCalculator.call(collection: cash_transactions),
          regular:,
        )
      end

      def categorised_bank_transactions(other_income_payments, category)
        incomes = other_income_payments.select { _1.category == category }
        if incomes.present?
          Calculators::MonthlyEquivalentCalculator.call(collection: incomes)
        else
          0
        end
      end
    end
  end
end
