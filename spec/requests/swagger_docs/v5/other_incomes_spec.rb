require "swagger_helper"

RSpec.describe "other_incomes", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/other_incomes" do
    post("create other_income") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Add applicant's other income payments to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "A set of other regular income sources",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/other_incomes.json"))),
                  properties: {
                    other_incomes: { "$ref" => "#/components/schemas/OtherIncomes" },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          JSON.parse(file_fixture("other_incomes.json").read)
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
            other_incomes: [
              {
                source: "foobar",
                payments: [],
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/other_incomes\/0\/source' value "foobar" did not match one of the following values: benefits, friends_or_family, maintenance_in, property_or_lodger, pension, Benefits, Friends or family, Maintenance in, Property or lodger, Pension in schema/)
        end
      end
    end
  end
end
