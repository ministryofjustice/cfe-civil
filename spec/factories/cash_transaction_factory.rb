FactoryBot.define do
  factory :cash_transaction do
    initialize_with { new(**attributes) }

    date { Date.current }
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    client_id { Faker::Internet.uuid }
  end
end
