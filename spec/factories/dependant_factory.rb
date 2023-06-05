FactoryBot.define do
  factory :dependant do
    initialize_with { new(**attributes) }
    date_of_birth { Faker::Date.birthday }
    in_full_time_education { [true, false].sample }
    relationship { %w[child_relative adult_relative].sample }
    monthly_income { 0.0 }
    assets_value { 0.0 }

    trait :child_relative do
      relationship { :child_relative }
      date_of_birth { submission_date - 16.years + 1.day }
    end

    trait :adult_relative do
      relationship { :adult_relative }
      date_of_birth { submission_date - 16.years }
    end

    trait :under15 do
      relationship { "child_relative" }
      date_of_birth { Faker::Date.between(from: submission_date - 15.years + 1.day, to: submission_date - 1.day) }
    end

    trait :aged15 do
      relationship { "child_relative" }
      date_of_birth { Faker::Date.between(from: submission_date - 16.years + 1.day, to: submission_date - 15.years) }
    end

    trait :aged16or17 do
      relationship { "child_relative" }
      date_of_birth { Faker::Date.between(from: submission_date - 18.years + 1.day, to: submission_date - 16.years) }
    end

    trait :over18 do
      date_of_birth { Faker::Date.between(from: submission_date - 65.years, to: submission_date - 18.years) }
    end
  end
end
