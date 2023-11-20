FactoryBot.define do
  factory :person_data do
    initialize_with { new(**attributes) }
    employment_details { [] }
    self_employments { [] }
    employments { [] }
    dependants { [] }
    outgoings { [] }
    capitals_data
    state_benefits { [] }
    other_income_payments { [] }
    regular_transactions { [] }
  end

  factory :capitals_data do
    initialize_with { new(**attributes) }

    vehicles { [] }
    non_liquid_capital_items { [] }
    liquid_capital_items { [] }
    main_home { {} }
    additional_properties { [] }
  end
end
