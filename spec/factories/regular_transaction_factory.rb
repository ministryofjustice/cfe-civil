FactoryBot.define do
  factory :regular_transaction do
    association :gross_income_summary
    category { "maintenance_in" }
    operation { "credit" }
    frequency { "four_weekly" }
    amount { "9.99" }

    factory :housing_cost do
      category { "rent_or_mortgage" }
      operation { "debit" }
    end

    trait :pension_contribution do
      category { "pension_contribution" }
      operation { "debit" }
    end

    factory :housing_benefit_regular do
      category { "housing_benefit" }
      operation { "credit" }
    end
  end
end
