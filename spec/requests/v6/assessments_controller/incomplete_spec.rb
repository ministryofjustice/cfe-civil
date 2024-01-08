require "rails_helper"

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, :calls_lfa, type: :request do
    let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
    let(:overall_result) { v6_overall_result(parsed_response) }
    let(:gross_result) { v6_gross_result(parsed_response) }
    let(:disposable_result) { v6_disposable_result(parsed_response) }
    let(:capital_result) { v6_capital_result(parsed_response) }
    let(:user_agent) { Faker::ProgrammingLanguage.name }
    let(:params) do
      v6_params(gross_complete:, disp_complete:, capital_complete:, passported:, monthly_gross_income:, monthly_disposable:, capital:)
    end

    context "when passported" do
      let(:body) do
        { assessment: { submission_date: "2024-01-04",
                        level_of_help: "certificated" },
          proceeding_types: [{ ccms_code: "SE003",
                               client_involvement_type: "A" }],
          vehicles: [{ value: 1.0, loan_amount_outstanding: 5.0, date_of_purchase: "2022-01-04", in_regular_use: false, subject_matter_of_dispute: false }],
          capitals: {
            bank_accounts: [],
            non_liquid_capital: [{ value: 800.0, description: "Non Liquid Asset", subject_matter_of_dispute: false }],
          },
          applicant: { date_of_birth: "1974-01-04", receives_qualifying_benefit: true } }
      end

      before do
        post v6_assessments_path, params: body.to_json, headers:
      end

      it "does not error" do
        expect(parsed_response[:errors]).to be_nil
      end

      it "doesnt calculate gross or disposable" do
        expect([overall_result, gross_result, disposable_result, capital_result]).to eq(%i[eligible not_calculated not_calculated eligible])
      end
    end

    context "with certificated" do
      let(:level_of_help) { "certificated" }

      before do
        post v6_assessments_path, params: params.to_json, headers:
      end

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

          it "is ineligible as once the threshold is hit it can only get worse" do
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

    context "with controlled" do
      let(:level_of_help) { "controlled" }
      let(:passported) { false }

      let(:tests) do
        [
          { gc: "complete", g: 2000, dc: "complete", d: 0, cc: "complete", c: 4000, or: :eligible, gr: :eligible, dr: :eligible, cr: :eligible },
          { gc: "complete", g: 2000, dc: "complete", d: 0, cc: "incomplete", c: 4000, or: :not_yet_known, gr: :eligible, dr: :eligible, cr: :not_yet_known },
          # incomplete capital but above capital threshold
          { gc: "complete", g: 2000, dc: "complete", d: 0, cc: "incomplete", c: 9000, or: :ineligible, gr: :eligible, dr: :eligible, cr: :ineligible },
          # on the disposable threshold, we know we are eligible as outgoings can only make us more eligible
          { gc: "complete", g: 2000, dc: "incomplete", d: 733, cc: "complete", c: 4000, or: :eligible, gr: :eligible, dr: :eligible, cr: :eligible },
          # # above the disposable threshold things are uncertain, as we might have another undisclosed outgoing
          { gc: "complete", g: 2000, dc: "incomplete", d: 734, cc: "complete", c: 4000, or: :not_yet_known, gr: :eligible, dr: :not_yet_known, cr: :eligible },
          # over capital threshold means that we are ineligible whatever happens
          { gc: "complete", g: 2000, dc: "incomplete", d: 734, cc: "complete", c: 9000, or: :ineligible, gr: :eligible, dr: :not_yet_known, cr: :ineligible },
          { gc: "complete", g: 0, dc: "incomplete", d: 0, cc: "complete", c: 9000, or: :ineligible, gr: :eligible, dr: :eligible, cr: :ineligible },
          { gc: "complete", g: 0, dc: "incomplete", d: 0, cc: "incomplete", c: 4000, or: :not_yet_known, gr: :eligible, dr: :eligible, cr: :not_yet_known },
          { gc: "complete", g: 0, dc: "incomplete", d: 0, cc: "incomplete", c: 9000, or: :ineligible, gr: :eligible, dr: :eligible, cr: :ineligible },
          { gc: "incomplete", g: 0, dc: "complete", d: 0, cc: "complete", c: 4000, or: :not_yet_known, gr: :not_yet_known, dr: :eligible, cr: :eligible },
          { gc: "incomplete", g: 0, dc: "complete", d: 0, cc: "complete", c: 9000, or: :ineligible, gr: :not_yet_known, dr: :eligible, cr: :ineligible },
          { gc: "incomplete", g: 0, dc: "incomplete", d: 0, cc: "complete", c: 50_000, or: :ineligible, gr: :not_yet_known, dr: :eligible, cr: :ineligible },
        ]
      end

      it "handles all examples correctly" do
        tests.each_with_index do |test, index|
          test_params = v6_params(gross_complete: test.fetch(:gc),
                                  disp_complete: test.fetch(:dc),
                                  capital_complete: test.fetch(:cc),
                                  passported: false,
                                  monthly_gross_income: test.fetch(:g),
                                  monthly_disposable: test.fetch(:d),
                                  capital: test.fetch(:c))
          post(v6_assessments_path, params: test_params.to_json, headers:)
          actual = [v6_overall_result(parsed_response), v6_gross_result(parsed_response), v6_disposable_result(parsed_response), v6_capital_result(parsed_response)]
          expected = [test.fetch(:or), test.fetch(:gr), test.fetch(:dr), test.fetch(:cr)]
          expect(actual).to eq(expected), "Example #{index + 1} failed"
        end
      end
    end

    def v6_params(gross_complete:, disp_complete:, capital_complete:, passported:, monthly_gross_income:, monthly_disposable:, capital:)
      {
        assessment: { submission_date: "2023-11-23",
                      level_of_help:,
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
        capitals: {
          bank_accounts: [attributes_for(:liquid_capital_item, value: capital)],
        },
        proceeding_types: [{ ccms_code: "SE013", client_involvement_type: "A" }],
      }
    end

    def v6_overall_result(parsed_response)
      parsed_response.dig(:result_summary, :overall_result, :result).to_sym
    end

    def v6_gross_result(parsed_response)
      parsed_response.dig(:result_summary, :gross_income, :proceeding_types).first.fetch(:result).to_sym
    end

    def v6_disposable_result(parsed_response)
      parsed_response.dig(:result_summary, :disposable_income, :proceeding_types).first.fetch(:result).to_sym
    end

    def v6_capital_result(parsed_response)
      parsed_response.dig(:result_summary, :capital, :proceeding_types).first.fetch(:result).to_sym
    end
  end
end
