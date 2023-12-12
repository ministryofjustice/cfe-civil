FactoryBot.define do
  factory :assessment do
    sequence(:client_reference_id) { |n| sprintf("CLIENT-REF-%<number>04d", number: n) }
    remote_ip { Faker::Internet.ip_v4_address }
    submission_date { Date.current }
    level_of_help { "certificated" }
    controlled_legal_representation { false }
    not_aggregated_no_income_low_capital { false }
    transient do
      # the proceedings transient is an array of arrays, each item comprising a proceeding type code and it's associated client involvement type,
      # e.g. [ ['DA003', 'A'], ['SE014', 'Z']]
      proceedings { [%w[SE003 A]] }

      # use :with_child_dependants: 2 to create 2 children for the assessment
      with_child_dependants { 0 }
    end

    after(:create) do |record, evaluator|
      # create proceeding types if specified
      evaluator.proceedings.each do |proceeding|
        ptc, cit = proceeding
        unlimited = ptc.match?(/^DA/) && cit == "A"
        giu = unlimited ? 999_999_999_999 : 2657.0
        diu = unlimited ? 999_999_999_999 : 733.0
        capu = unlimited ? 999_999_999_999 : 8_000.0
        pt_rec = build :proceeding_type,
                       ccms_code: ptc,
                       client_involvement_type: cit,
                       gross_income_upper_threshold: giu,
                       disposable_income_upper_threshold: diu,
                       capital_upper_threshold: capu
        record.proceeding_types << pt_rec
      end

      record.save!
    end

    trait :with_disposable_income_summary do
      after(:create) do |assessment|
        create :disposable_income_summary, assessment:
      end
    end

    trait :with_gross_income_summary do
      after(:create) do |assessment|
        create :gross_income_summary, assessment:
      end
    end

    trait :with_gross_income_summary_and_employment do
      after(:create) do |assessment|
        create :gross_income_summary, assessment:
      end
    end

    trait :with_everything do
      after(:create) do |assessment|
        create(:gross_income_summary, assessment:)
        create(:disposable_income_summary, assessment:)
      end
    end
  end
end
