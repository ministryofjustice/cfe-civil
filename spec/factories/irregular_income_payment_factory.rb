FactoryBot.define do
  factory :irregular_income_payment do
    gross_income_summary
    income_type { "student_loan" }
    frequency { "annual" }

    factory :student_loan_payment do
      income_type { "student_loan" }
    end

    factory :unspecified_source_payment do
      income_type { "unspecified_source" }
      frequency { "monthly" }
    end
  end
end
