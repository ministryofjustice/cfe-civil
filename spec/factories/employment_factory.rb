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

    transient do
      # everything in CFE revolves around (assessment) submission_date, so this can never sensibly be defaulted
      submission_date { nil }
    end

    trait :with_monthly_payments do
      after(:build) do |record, evaluator|
        [evaluator.submission_date,
         evaluator.submission_date - 1.month,
         evaluator.submission_date - 2.months].each do |date|
          record.employment_payments << build(:employment_payment, date:, gross_income: evaluator.gross_monthly_income)
        end
      end
    end

    factory :partner_employment, class: "PartnerEmployment" do
    end
  end

  trait :with_irregular_payments do
    after(:build) do |record, evaluator|
      [evaluator.submission_date,
       evaluator.submission_date - 32.days,
       evaluator.submission_date - 64.days].each do |date|
        record.employment_payments << (build :employment_payment, date:, gross_income: 1500)
      end
    end
  end
end
