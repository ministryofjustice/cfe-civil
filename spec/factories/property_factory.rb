FactoryBot.define do
  factory :property, class: "Property" do
    initialize_with { new(**attributes) }

    value { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_f }
    outstanding_mortgage { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_f }
    percentage_owned { 100 }
    main_home { [true, false].sample }
    shared_with_housing_assoc { false }
    subject_matter_of_dispute { false }

    trait :main_home do
      main_home { true }
    end

    trait :additional_property do
      main_home { false }
    end

    trait :shared_ownership do
      shared_with_housing_assoc { true }
    end

    trait :not_shared_ownership do
      shared_with_housing_assoc { false }
    end
  end
end
