FactoryBot.define do
  factory :regular_transaction do
    initialize_with { new(**attributes) }

    category { :maintenance_in }
    operation { :credit }
    frequency { "four_weekly" }
    amount { 9.99 }

    factory :housing_cost do
      category { :rent_or_mortgage }
      operation { :debit }
    end

    trait :pension_contribution do
      category { :pension_contribution }
      operation { :debit }
    end

    factory :housing_benefit_regular do
      category { :housing_benefit }
      operation { :credit }
    end

    trait :council_tax do
      category { :council_tax }
      operation { :debit }
    end

    trait :priority_debt_repayment do
      category { :priority_debt_repayment }
      operation { :debit }
    end
  end
end
