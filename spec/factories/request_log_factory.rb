FactoryBot.define do
  factory :request_log do
    http_status { 200 }
    request { { assessment: {}, applicant: {}, proceeding_types: [] } }
    response do
      {
        version: "6",
        timestamp: Time.zone.now,
        success: true,
        assessment: { client_reference_id: nil, submission_date: "2023-05-08" },
      }
    end
    duration { 0.235087185 }
    user_agent { Faker::Internet.user_agent }

    trait :error do
      http_status { 422 }
      response do
        {
          success: false, errors: ["some error"]
        }
      end
    end
  end
end
