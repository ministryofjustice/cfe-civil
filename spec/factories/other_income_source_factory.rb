require Rails.root.join("spec/support/faker/other_income_source.rb")

FactoryBot.define do
  factory :other_income_source do
    gross_income_summary
    name { CFEConstants::VALID_INCOME_CATEGORIES.sample }
    monthly_income { nil }

    trait :with_monthly_payments do
      after(:create) do |record|
        [record.assessment.submission_date,
         record.assessment.submission_date - 1.month,
         record.assessment.submission_date - 2.months].each do |date|
          create :other_income_payment, other_income_source: record, amount: 75.0, payment_date: date, client_id: SecureRandom.uuid
        end
      end
    end
  end
end
