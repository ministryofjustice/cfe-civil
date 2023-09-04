FactoryBot.define do
  factory :employment, class: "Employment" do
    initialize_with { new(**attributes) }

    client_id { SecureRandom.uuid }
    sequence(:name) { |n| sprintf("Job %04d", n) }

    receiving_only_statutory_sick_or_maternity_pay { nil }
    employment_payments { [] }

    transient do
      gross_monthly_income { 1500 }
    end

    trait :with_monthly_payments do
      after(:build) do |record, evaluator|
        [record.submission_date,
         record.submission_date - 1.month,
         record.submission_date - 2.months].each do |date|
          record.employment_payments << build(:employment_payment, date:, gross_income: evaluator.gross_monthly_income)
        end
      end
    end

    factory :partner_employment, class: "PartnerEmployment" do
    end
  end

  trait :with_irregular_payments do
    after(:build) do |record|
      [record.submission_date,
       record.submission_date - 32.days,
       record.submission_date - 64.days].each do |date|
        record.employment_payments << (build :employment_payment, date:, gross_income: 1500)
      end
    end
  end
end
