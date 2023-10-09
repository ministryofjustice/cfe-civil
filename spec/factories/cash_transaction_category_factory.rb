FactoryBot.define do
  factory :cash_transaction_category do
    association(:gross_income_summary)
    operation { nil }
    name { nil }

    trait :credit do
      operation { "credit" }
      name { CFEConstants::VALID_INCOME_CATEGORIES.sample }
    end

    factory :child_care_transaction_category do
      operation { "debit" }
      name { "child_care" }
    end

    factory :rent_or_mortgage_transaction_category do
      name { "rent_or_mortgage" }
      operation { "debit" }
    end
  end
end
