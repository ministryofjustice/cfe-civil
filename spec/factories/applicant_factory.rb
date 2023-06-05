FactoryBot.define do
  factory :applicant do
    initialize_with { new(**attributes) }

    employed { false }
    receives_asylum_support { false }
    date_of_birth { Faker::Date.between(from: 18.years.ago, to: 49.years.ago) }
    receives_qualifying_benefit { false }

    trait :with_qualifying_benefits do
      receives_qualifying_benefit { true }
    end

    trait :without_qualifying_benefits do
      receives_qualifying_benefit { false }
    end

    trait :under_pensionable_age do
      date_of_birth { 49.years.ago.to_date }
    end

    trait :over_pensionable_age do
      date_of_birth { 71.years.ago.to_date }
    end
  end
end
