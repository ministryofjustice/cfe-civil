require "rails_helper"

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, type: :request do
    let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
    let(:user_agent) { Faker::ProgrammingLanguage.name }
    let(:params) do
      {
        assessment: { submission_date: "2023-11-23",
                      section_gross_income: gross_complete,
                      section_disposable_income: disp_complete,
                      section_capital: capital_complete },
        applicant: { date_of_birth: "2001-02-02",
                     receives_qualifying_benefit: passported },
        irregular_incomes: { payments: [{ income_type: "unspecified_source", frequency: "monthly", amount: monthly_gross_income }] },
        outgoings: [{ name: "legal_aid",
                      payments: [
                        { payment_date: "2023-08-23", amount: monthly_gross_income - monthly_disposable, client_id: SecureRandom.uuid },
                        { payment_date: "2023-09-23", amount: monthly_gross_income - monthly_disposable, client_id: SecureRandom.uuid },
                        { payment_date: "2023-10-23", amount: monthly_gross_income - monthly_disposable, client_id: SecureRandom.uuid },
                      ] }],
        vehicles: [attributes_for(:vehicle, value: capital, loan_amount_outstanding: 0, date_of_purchase: "2022-03-05", in_regular_use: false)],
        proceeding_types: [{ ccms_code: "SE013", client_involvement_type: "A" }],
      }
    end

    describe "POST /create" do
      before do
        post v6_assessments_path, params: params.to_json, headers:
      end

      let(:overall_result) { parsed_response.dig(:result_summary, :overall_result, :result).to_sym }
      let(:gross_result) { parsed_response.dig(:result_summary, :gross_income, :proceeding_types).first.fetch(:result).to_sym }
      let(:disposable_result) { parsed_response.dig(:result_summary, :disposable_income, :proceeding_types).first.fetch(:result).to_sym }
      let(:capital_result) { parsed_response.dig(:result_summary, :capital, :proceeding_types).first.fetch(:result).to_sym }

      context "with all sections complete" do
        let(:gross_complete) { "complete" }
        let(:disp_complete) { "complete" }
        let(:capital_complete) { "complete" }
        let(:monthly_gross_income) { 2 }
        let(:monthly_disposable) { 1 }
        let(:capital) { 1 }
        let(:passported) { false }

        it "is all eligible" do
          expect([overall_result, gross_result]).to eq(%i[eligible eligible])
        end
      end

      context "when passported" do
        let(:gross_complete) { "complete" }
        let(:disp_complete) { "complete" }
        let(:capital_complete) { "complete" }
        let(:monthly_gross_income) { 0 }
        let(:monthly_disposable) { 0 }
        let(:capital) { 1 }
        let(:passported) { true }

        it "is eligible apart from uncalculated sections" do
          expect([overall_result, gross_result, disposable_result, capital_result]).to eq(%i[eligible not_calculated not_calculated eligible])
        end
      end

      context "when the gross income section is incomplete" do
        let(:gross_complete) { "incomplete" }
        let(:disp_complete) { "complete" }
        let(:capital_complete) { "complete" }
        let(:monthly_disposable) { 200 }
        let(:capital) { 1 }
        let(:passported) { false }

        context "when below upper threshold" do
          let(:monthly_gross_income) { 2656 }

          it "is unknown" do
            expect([overall_result, gross_result]).to eq(%i[not_yet_known not_yet_known])
          end
        end

        context "when above upper threshold" do
          let(:monthly_gross_income) { 2657 }

          it "is ineligible" do
            expect([overall_result, gross_result]).to eq(%i[ineligible ineligible])
          end
        end
      end

      context "when the disposable income section is incomplete" do
        let(:gross_complete) { "complete" }
        let(:disp_complete) { "incomplete" }
        let(:capital_complete) { "complete" }
        let(:monthly_gross_income) { 2000 }
        let(:capital) { 1 }
        let(:passported) { false }

        context "when below disposable lower threshold" do
          let(:monthly_disposable) { 315 }

          it "is eligible" do
            expect([overall_result, gross_result, disposable_result]).to eq(%i[eligible eligible eligible])
          end
        end

        context "when below disposable upper threshold" do
          let(:monthly_disposable) { 732 }

          it "is not known, as extra outgoings might push us under the lower threshold" do
            expect([overall_result, gross_result, disposable_result]).to eq(%i[not_yet_known eligible not_yet_known])
          end
        end

        context "when above upper threshold" do
          let(:monthly_disposable) { 734 }

          it "cannot be calculated" do
            expect([overall_result, gross_result, disposable_result]).to eq(%i[not_yet_known eligible not_yet_known])
          end
        end
      end

      context "when the capital section is incomplete" do
        let(:gross_complete) { "complete" }
        let(:disp_complete) { "complete" }
        let(:capital_complete) { "incomplete" }
        let(:monthly_gross_income) { 2000 }
        let(:monthly_disposable) { 314 }
        let(:passported) { false }

        context "when below upper capital threshold" do
          let(:capital) { 4000 }

          it "cant be known yet" do
            expect([overall_result, gross_result, disposable_result, capital_result]).to eq(%i[not_yet_known eligible eligible not_yet_known])
          end
        end

        context "when above threshold" do
          let(:capital) { 9000 }

          it "is ineligible" do
            expect([overall_result, gross_result, disposable_result, capital_result]).to eq(%i[ineligible eligible eligible ineligible])
          end
        end
      end
    end
  end
end
