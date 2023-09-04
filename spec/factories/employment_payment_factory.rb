FactoryBot.define do
  factory :employment_payment, class: "EmploymentPayment" do
    initialize_with { new(**attributes) }

    client_id { SecureRandom.uuid }
    gross_income { Faker::Number.between(from: 2022.35, to: 3096.52).round(2) }
    benefits_in_kind { 23.87 }
    tax { (gross_income * 0.33).round(2) * -1 }
    national_insurance { (gross_income * 0.1).round(2) * -1 }
  end
end
