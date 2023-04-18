require "rails_helper"
require "swagger_helper"

RSpec.describe "applicants", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/applicant" do
    post("create applicant") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description << "This endpoint will create an Applicant and associate it with an existing Assessment which has been created via `POST /assessments`"

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[applicant],
                  properties: {
                    applicant: { "$ref" => "#/components/schemas/Applicant" },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, version: "5").id }

        let(:params) do
          {
            applicant: {
              date_of_birth: "1992-07-22",
              has_partner_opponent: false,
              receives_qualifying_benefit: true,
            },
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

      response(422, "Unprocessable Entity") do\
        let(:assessment_id) { create(:assessment, version: "5").id }

        let(:params) do
          {
            applicant: {
              has_partner_opponent: false,
              receives_qualifying_benefit: true,
            },
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/applicant' did not contain a required property of 'date_of_birth' in schema/)
        end
      end
    end
  end
end
