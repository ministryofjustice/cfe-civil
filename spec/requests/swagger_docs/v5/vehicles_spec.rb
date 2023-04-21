require "swagger_helper"

RSpec.describe "vehicles", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/vehicles" do
    post("create vehicle") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Add applicant's outgoings to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "Details of all vehicles owned by the applicant for certificated work, "\
                               "and all vehicles owned by the applicant that are in regular use for controlled work",
                  example: { vehicles: [{ value: 10_000.01, loan_amount_outstanding: 9999.99, date_of_purchase: "2020-01-27", in_regular_use: true }] },
                  properties: {
                    vehicles: {
                      type: :array,
                      description: "One or more vehicles' details",
                      items: { "$ref" => "#/components/schemas/Vehicle" },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, :with_capital_summary).id }

        let(:params) do
          {
            vehicles: [
              {
                value: 1817.19,
                loan_amount_outstanding: 1361.65,
                date_of_purchase: "2021-02-14",
                in_regular_use: true,
                subject_matter_of_dispute: true,
              },
            ],
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
        let(:assessment_id) { create(:assessment, :with_capital_summary).id }

        let(:params) do
          {
            vehicles: [
              {
                loan_amount_outstanding: 1361.65,
                date_of_purchase: "2021-02-14",
                in_regular_use: true,
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/vehicles\/0' did not contain a required property of 'value' in schema/)
        end
      end
    end
  end
end
