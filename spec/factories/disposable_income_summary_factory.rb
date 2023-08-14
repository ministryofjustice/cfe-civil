FactoryBot.define do
  factory :disposable_income_summary do
    association :assessment

    trait :with_everything do
      after(:create) do |record|
        [record.assessment.submission_date,
         record.assessment.submission_date - 1.month,
         record.assessment.submission_date - 2.months].each do |date|
          create :childcare_outgoing, disposable_income_summary: record, payment_date: date, amount: 100
          create :maintenance_outgoing, disposable_income_summary: record, payment_date: date, amount: 50
          create :housing_cost_outgoing, disposable_income_summary: record, payment_date: date, amount: 125
          create :legal_aid_outgoing, disposable_income_summary: record, payment_date: date, amount: 363
        end
      end
    end

    trait :with_eligibilities do
      after(:create) do |rec|
        rec.assessment.proceeding_type_codes.each do |ptc|
          create :disposable_income_eligibility, disposable_income_summary: rec, proceeding_type_code: ptc
        end
      end
    end

    factory :partner_disposable_income_summary do
      type { "PartnerDisposableIncomeSummary" }
    end
  end
end
