FactoryBot.define do
  factory :childcare_outgoing, class: "Outgoings::Childcare" do
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end

  factory :housing_cost_outgoing, class: "Outgoings::HousingCost" do
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    housing_cost_type { "rent" }
  end

  factory :maintenance_outgoing, class: "Outgoings::Maintenance" do
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end

  factory :legal_aid_outgoing, class: "Outgoings::LegalAid" do
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end

  factory :pension_contribution_outgoing, class: "Outgoings::PensionContribution" do
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end

  factory :council_tax_outgoing, class: "Outgoings::CouncilTax" do
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
