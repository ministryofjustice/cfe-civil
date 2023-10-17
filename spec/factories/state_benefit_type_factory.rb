FactoryBot.define do
  factory :state_benefit_type do
    sequence :label do |n|
      "benefit_type_#{n + 100}"
    end
    # make the name different so that it closer matches the seeded data
    name { label.titleize }
    sequence :dwp_code do |n|
      [nil, "#{('A'..'Z').to_a.sample(2).join}#{n}"].sample
    end
    exclude_from_gross_income { [true, false].sample }
    category { (%w[carer_disability low_income other uncategorised] + [nil]).sample }

    trait :other do
      label { "other" }
      name { "Other state benefit type" }
      exclude_from_gross_income { false }
    end

    trait :benefit_excluded do
      exclude_from_gross_income { true }
    end

    trait :benefit_included do
      exclude_from_gross_income { false }
    end

    trait :universal_credit do
      label { "universal_credit" }
      name { "Universal Credit" }
      exclude_from_gross_income { false }
      dwp_code { "UC" }
    end

    trait :child_benefit do
      label { "child_benefit" }
      name { "Child Benefit" }
      exclude_from_gross_income { false }
      dwp_code { "CHB" }
    end

    trait :housing_benefit do
      label { "housing_benefit" }
      exclude_from_gross_income { true }
    end
  end
end
