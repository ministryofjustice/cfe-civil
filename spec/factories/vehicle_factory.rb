FactoryBot.define do
  factory :vehicle do
    initialize_with { new(**attributes) }
    value { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    loan_amount_outstanding { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    date_of_purchase { 4.years.ago }
    in_regular_use { true }
    subject_matter_of_dispute { false }
  end
end
