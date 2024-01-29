FactoryBot.define do
  factory :assessment do
    sequence(:client_reference_id) { |n| sprintf("CLIENT-REF-%<number>04d", number: n) }
    remote_ip { Faker::Internet.ip_v4_address }
    submission_date { Date.current }
    level_of_help { "certificated" }
    controlled_legal_representation { false }
    not_aggregated_no_income_low_capital { false }
    transient do
      # use :with_child_dependants: 2 to create 2 children for the assessment
      with_child_dependants { 0 }
    end
  end
end
