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

    trait :with_response_remarks do
      response do
        {
          version: "6",
          timestamp: Time.zone.now,
          success: true,
          assessment: {
            client_reference_id: nil,
            submission_date: "2023-05-08",
            remarks: {
              employment_tax: {
                refunds: %w[
                  05459c0f-a620-4743-9f0c-b3daa93e571
                ],
              },
              employment_nic: {
                refunds: %w[
                  05459c0f-a620-4743-9f0c-b3daa93e571
                ],
              },
              state_benefit_payment: {
                unknown_frequency: %w[
                  05459c0f-a620-4743-9f0c-b3daa9
                  E
                ],
                multi_benefit: %w[
                  05459c0f-a620-4743-9f0c-b3daa9
                ],
              },
              other_income_payment: {
                unknown_frequency: %w[
                  05459c0f-a620-4743-9f0c-b3daa93e
                ],
              },
              outgoings_housing_cost: {
                unknown_frequency: %w[
                  05459c0f-a620-4743-9f0c-b3daa93e5
                ],
              },
              employment_payment: {
                unknown_frequency: %w[
                  05459c0f-a620-4743-9f0c-b3daa93e571
                  C
                ],
              },
              policy_disregards: %w[
                string
              ],
            },
          },
        }
      end
    end

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
