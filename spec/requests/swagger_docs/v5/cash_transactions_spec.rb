require "swagger_helper"

RSpec.describe "cash_transactions", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/cash_transactions" do
    post("create cash_transaction") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description "Add cash income and outgoings to an assessment."

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: { "$ref" => "#/components/schemas/CashTransactions" }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          source = file_fixture("cash_transactions.json").read
          updated = source.gsub("3.months.ago", 3.months.ago.beginning_of_month.strftime("%Y-%m-%d"))
                          .gsub("2.months.ago", 2.months.ago.beginning_of_month.strftime("%Y-%m-%d"))
                          .gsub("1.month.ago", 1.month.ago.beginning_of_month.strftime("%Y-%m-%d"))
          JSON.parse(updated)
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
            income: [
              {
                category: "maintenance_out",
                payments: [],
              },
            ],
            outgoings: [
              {
                category: "maintenance_in",
                payments: [],
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/income\/0\/category' value "maintenance_out" did not match one of the following values/)
          expect(body[:errors]).to include(/The property '#\/outgoings\/0\/category' value "maintenance_in" did not match one of the following values/)
        end
      end
    end
  end
end
