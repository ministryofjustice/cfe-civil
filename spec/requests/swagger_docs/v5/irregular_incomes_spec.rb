require "swagger_helper"

RSpec.describe "irregular_incomes", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/irregular_incomes" do
    post("create irregular_income") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Add applicant's irregular income payments to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "A set of irregular income payments",
                  example: { payments: [{ income_type: "student_loan", frequency: "annual", amount: 123_456.78 }] },
                  required: %i[payments],
                  properties: {
                    payments: { "$ref" => "#/components/schemas/IrregularIncomePayments" },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          {
            payments: [
              {
                income_type: "student_loan",
                frequency: "annual",
                amount: 123_456.78,
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
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          {
            payments: [
              {
                frequency: "annual",
                amount: 123_456.78,
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors])
            .to include(/The property '#\/payments\/0' did not contain a required property of 'income_type' in schema/)
        end
      end
    end
  end
end
