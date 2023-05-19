require "swagger_helper"

RSpec.describe "V5 Assessments", type: :request, vcr: true, swagger_doc: "v5/swagger.yaml" do
  path "/assessments" do
    post("create assessment") do
      tags "Assessment"
      consumes "application/json"
      produces "application/json"

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  "$ref" => "#/components/schemas/CertificatedAssessment",
                }

      # rubocop:disable RSpec/VariableName
      let(:Accept) { "application/json;version=5" }
      # rubocop:enable RSpec/VariableName

      response(200, "successful") do
        let(:params) do
          {
            submission_date: "2022-05-19",
          }
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        run_test!
      end

      response(422, "Unprocessable Entity") do
        let(:params) { {} }

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/' did not contain a required property of 'submission_date'/)
        end
      end
    end
  end

  path "/assessments/{id}" do
    parameter name: :id, in: :path, type: :string, description: "Unique identifier of the assessment"

    get("show assessment") do
      tags "Assessment"
      produces "application/json"

      response(200, "successful") do
        let(:assessment) { create(:assessment, :passported, :with_everything) }
        let(:id) { assessment.id }

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
