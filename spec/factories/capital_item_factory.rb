FactoryBot.define do
  factory :non_liquid_capital_item, class: "CapitalItem" do
    initialize_with { new(**attributes) }

    description { Faker::Lorem.unique.sentence }
    value { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_d(Float::DIG) }
    subject_matter_of_dispute { false }
  end

  factory :liquid_capital_item, class: "CapitalItem" do
    initialize_with { new(**attributes) }

    description { Faker::Lorem.unique.sentence }
    value { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_d(Float::DIG) }
    subject_matter_of_dispute { false }

    trait :negative do
      value { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_d(Float::DIG) * -1 }
    end
  end
end
