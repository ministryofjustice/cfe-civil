require "swagger_helper"

RSpec.describe "state_benefits", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/state_benefits" do
    post("create state_benefit") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Add applicant's state benefits to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "A set of other regular income sources",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/state_benefits.json"))),
                  properties: {
                    required: %i[state_benefits],
                    additionalProperties: false,
                    state_benefits: {
                      type: :array,
                      description: "One or more state benefits receved by the applicant and categorized by name",
                      items: { "$ref" => "#/components/schemas/StateBenefit" },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        before { create(:state_benefit_type, :other) }

        let(:params) do
          JSON.parse(file_fixture("state_benefits.json").read)
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
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          {
            state_benefits: [
              {
                payments: [],
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/state_benefits\/0' did not contain a required property of 'name' in schema/)
        end
      end
    end
  end
end
