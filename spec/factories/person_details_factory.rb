FactoryBot.define do
  factory :person_data do
    initialize_with { new(**attributes) }
    employment_details { [] }
    self_employments { [] }
    vehicles { [] }
    dependants { [] }
    non_liquid_capital_items { [] }
    liquid_capital_items { [] }
  end
end
