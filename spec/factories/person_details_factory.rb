FactoryBot.define do
  factory :person_data do
    initialize_with { new(**attributes) }
    employment_details { [] }
    self_employments { [] }
    vehicles { [] }
    dependants { [] }
  end
end
