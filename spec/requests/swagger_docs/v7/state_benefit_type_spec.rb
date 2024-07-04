require "swagger_helper"

## Duplicate spec in spec/requests/swagger_docs/v6 to make it appear in swagger API documentation with multiple versions
RSpec.describe "state_benefit_type", swagger_doc: "v7/swagger.yaml", type: :request do
  path "/state_benefit_type" do
    get("list state_benefit_types") do
      tags "Lookups"
      produces "application/json"

      response(200, "successful") do
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        run_test!
      end
    end
  end
end
