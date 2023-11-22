FactoryBot.define do
  factory :other_income_payment do
    initialize_with { new(**attributes) }

    category { CFEConstants::VALID_INCOME_CATEGORIES.sample }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    client_id { SecureRandom.uuid }
    payment_date { Date.current }
  end
end
