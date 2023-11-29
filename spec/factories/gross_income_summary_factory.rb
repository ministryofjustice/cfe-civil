FactoryBot.define do
  factory :gross_income_summary do
    association :assessment

    trait :with_eligibilities do
      after(:create) do |rec|
        rec.assessment.proceeding_type_codes.each do |ptc|
          create :gross_income_eligibility, gross_income_summary: rec, proceeding_type_code: ptc
        end
      end
    end

    trait :with_irregular_income_payments do
      after(:create) do |gross_income_summary|
        create :state_benefit, :with_monthly_payments, gross_income_summary: gross_income_summary
        create :irregular_income_payment, gross_income_summary: gross_income_summary
      end
    end

    factory :partner_gross_income_summary do
      type { "PartnerGrossIncomeSummary" }
    end
  end
end
