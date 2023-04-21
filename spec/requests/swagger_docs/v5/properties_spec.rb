require "swagger_helper"

RSpec.describe "properties", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/properties" do
    post("create property") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Add applicant's properties to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[properties],
                  description: "A set consisting of a main home and additional properties",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/properties.json"))),
                  properties: {
                    properties: {
                      type: :object,
                      required: %i[main_home],
                      description: "A main home and additional properties",
                      properties: {
                        main_home: { "$ref" => "#/components/schemas/Property" },
                        additional_properties: {
                          type: :array,
                          description: "One or more additional properties owned by the applicant",
                          items: { "$ref" => "#/components/schemas/Property" },
                        },
                      },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, :with_capital_summary).id }

        let(:params) do
          JSON.parse(file_fixture("properties.json").read)
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
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          {
            properties: {
              main_home: {
                value: nil,
                outstanding_mortgage: 999.99,
                percentage_owned: 15.0,
                shared_with_housing_assoc: true,
                subject_matter_of_dispute: false,
              },
              additional_properties: [],
            },
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/properties\/main_home\/value' of type null did not match any of the required schemas/)
        end
      end
    end
  end
end
