module Collators
  class GrossIncomeCollator
    Result = Data.define(:remarks, :person_gross_income_subtotals)

    class << self
      EmploymentData = Data.define(:monthly_tax, :monthly_gross_income,
                                   :client_id,
                                   :entitles_employment_allowance?,
                                   :entitles_childcare_allowance?,
                                   :monthly_benefits_in_kind,
                                   :monthly_national_insurance,
                                   :monthly_prisoner_levy,
                                   :monthly_student_debt_repayment,
                                   :employment_name,
                                   :employment_payments)

      def call(submission_date:, person:)
        self_employments = convert_employment_details(person.self_employments)
        employment_details = convert_employment_details(person.employment_details)

        converted_employments_and_remarks = convert_employment_payments(person.employments, submission_date)
        employments = converted_employments_and_remarks.employment_data
        regular_transactions = person.regular_transactions
        other_income_payments = person.other_income_payments
        cash_transactions = person.cash_transactions

        employment_income_subtotals = derive_employment_income_subtotals(submission_date:, employments:, self_employments:, employment_details:)

        remarks = if employments.count > 1
                    [RemarksData.new(type: :employment, issue: :multiple_employments, ids: employments.map(&:client_id))]
                  else
                    []
                  end

        # It's useful to call this here to avoid confusion with filtering (which is done by StateBenefitsCalculator#benefits)
        # being done at different levels in the code
        state_benefit_results = Calculators::StateBenefitsCalculator.benefits(regular_transactions:,
                                                                              submission_date:, state_benefits: person.state_benefits)

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
          irregular_income_payments: person.irregular_income_payments,
          regular_income_categories:,
          employment_income_subtotals:,
          state_benefits: person.state_benefits,
        )

        Result.new(person_gross_income_subtotals:, remarks: remarks + converted_employments_and_remarks.remarks)
      end

    private

      # local define for employment and monthly_values
      EmploymentResult = Data.define(:employment, :values, :payments, :remarks)

      EmploymentDataAndRemarks = Data.define(:employment_data, :remarks)

      def convert_employment_payments(employments, submission_date)
        answers = employments.map do
          monthly_equivalent_payments = Utilities::EmploymentIncomeMonthlyEquivalentCalculator.call(_1.employment_payments)
          remarks_and_values = Calculators::EmploymentMonthlyValueCalculator.call(_1, submission_date, monthly_equivalent_payments)
          EmploymentResult.new employment: _1, values: remarks_and_values.values, payments: remarks_and_values.payments, remarks: remarks_and_values.remarks
        end

        employment_data = answers.map do
          EmploymentData.new(monthly_tax: _1.values.fetch(:monthly_tax),
                             monthly_gross_income: _1.values.fetch(:monthly_gross_income),
                             monthly_national_insurance: _1.values.fetch(:monthly_national_insurance),
                             monthly_prisoner_levy: _1.values.fetch(:monthly_prisoner_levy),
                             monthly_student_debt_repayment: _1.values.fetch(:monthly_student_debt_repayment),
                             entitles_employment_allowance?: _1.employment.entitles_employment_allowance?,
                             entitles_childcare_allowance?: _1.employment.entitles_childcare_allowance?,
                             client_id: _1.employment.client_id,
                             monthly_benefits_in_kind: _1.values.fetch(:monthly_benefits_in_kind),
                             employment_name: _1.employment.name,
                             employment_payments: _1.payments)
        end

        EmploymentDataAndRemarks.new(employment_data:, remarks: answers.map(&:remarks).flatten)
      end

      def convert_employment_details(employment_details)
        employment_details.map do |detail|
          monthly_gross_income = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.gross)
          monthly_national_insurance = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.national_insurance)
          monthly_prisoner_levy = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.prisoner_levy)
          monthly_student_debt_repayment = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.student_debt_repayment)
          monthly_tax = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.tax)
          monthly_benefits_in_kind = Utilities::MonthlyAmountConverter.call(detail.income.frequency, detail.income.benefits_in_kind)

          EmploymentData.new(monthly_tax:,
                             monthly_gross_income:,
                             monthly_national_insurance:,
                             monthly_prisoner_levy:,
                             monthly_student_debt_repayment:,
                             entitles_employment_allowance?: detail.income.entitles_employment_allowance?,
                             entitles_childcare_allowance?: detail.income.entitles_childcare_allowance?,
                             client_id: detail.client_reference,
                             monthly_benefits_in_kind:,
                             employment_name: nil,
                             employment_payments: [])
        end
      end

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
