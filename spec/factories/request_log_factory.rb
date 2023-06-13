FactoryBot.define do
  factory :request_log do
    http_status { 200 }
    response { "responding blah" }
    duration { 0.235087185 }
    user_agent { Faker::Internet.user_agent }
  end
end
