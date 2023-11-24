FactoryBot.define do
  factory :irregular_income_payment do
    initialize_with { new(**attributes) }

    income_type { :student_loan }
    frequency { "annual" }
    amount { 0 }

    factory :student_loan_payment do
      income_type { :student_loan }
    end

    factory :unspecified_source_payment do
      income_type { :unspecified_source }
      frequency { "monthly" }
    end
  end
end
