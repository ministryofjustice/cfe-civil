FactoryBot.define do
  factory :disposable_income_summary do
    association :assessment

    factory :partner_disposable_income_summary do
      type { "PartnerDisposableIncomeSummary" }
    end
  end
end
