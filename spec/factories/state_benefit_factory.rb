FactoryBot.define do
  factory :state_benefit do
    initialize_with { new(**attributes) }
    state_benefit_name { "anything" }
    exclude_from_gross_income { false }

    trait :housing_benefit do
      state_benefit_name { "housing_benefit" }
    end

    transient do
      payment_amount { 88.30 }
    end
  end
end
