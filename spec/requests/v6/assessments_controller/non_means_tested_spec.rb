require "rails_helper"

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, type: :request do
    let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
    let(:user_agent) { Faker::ProgrammingLanguage.name }
    let(:assessment_params) do
      {
        submission_date: "2023-11-23",
        level_of_help:,
      }
    end
    let(:default_params) do
      {
        assessment: assessment_params,
        applicant: {
          date_of_birth:,
          receives_qualifying_benefit: false,
        },
        vehicles: [attributes_for(:vehicle, value: 200_000, loan_amount_outstanding: 0, date_of_purchase: "2022-03-05", in_regular_use: false)],
      }
    end
    let(:proceeding_types) do
      { proceeding_types: attributes_for_list(:proceeding_type, 1) }
    end

    describe "POST /create" do
      before do
        post v6_assessments_path, params: default_params.merge(params).to_json, headers:
      end

      let(:overall_result) { parsed_response.dig(:result_summary, :overall_result, :result).to_sym }

      context "non means tested" do
        context "controlled" do
          let(:level_of_help) { "controlled" }

          context "when controlled_legal_representation(CLR)" do
            let(:assessment_params) do
              {
                submission_date: "2023-11-23",
                level_of_help:,
                controlled_legal_representation: true,
              }
            end

            context "when applicant under 18" do
              let(:date_of_birth) { "2010-02-02" }
              let(:params) { {} }

              it "is eligible for CLR work" do
                expect(overall_result).to eq(:eligible)
              end
            end

            context "when applicant over 18" do
              let(:date_of_birth) { "2000-02-02" }
              let(:params) { proceeding_types }

              it "is ineligible ignoring CLR work" do
                expect(overall_result).to eq(:ineligible)
              end
            end
          end

          context "when not controlled_legal_representation(CLR) and applicant is under 18" do
            let(:assessment_params) do
              {
                submission_date: "2023-11-23",
                level_of_help:,
                controlled_legal_representation: false,
              }
            end
            let(:date_of_birth) { "2010-02-02" }

            context "without proceeding_types" do
              let(:params) { {} }

              it "returns error" do
                expect(response).to have_http_status(:unprocessable_entity)
              end

              it "returns error JSON" do
                expect(parsed_response[:errors])
                  .to include(/This assessment is not non-means, so requires a proceeding_type/)
              end
            end

            context "with proceeding_types" do
              let(:params) { proceeding_types }

              it "is not_calculated" do
                expect(overall_result).to eq(:ineligible)
              end
            end
          end

          context "not_aggregated_no_income_low_capital" do
            let(:assessment_params) do
              {
                submission_date: "2023-11-23",
                level_of_help:,
                not_aggregated_no_income_low_capital: true,
              }
            end

            context "when applicant under 18" do
              let(:date_of_birth) { "2010-02-02" }
              let(:params) { {} }

              it "is eligible" do
                expect(overall_result).to eq(:eligible)
              end
            end

            context "when applicant over 18" do
              let(:date_of_birth) { "2000-02-02" }
              let(:params) { proceeding_types }

              it "is ineligible" do
                expect(overall_result).to eq(:ineligible)
              end
            end
          end
        end

        context "certificated" do
          let(:level_of_help) { "certificated" }

          context "when applicant under 18" do
            let(:date_of_birth) { "2010-02-02" }
            let(:params) { {} }

            it "is eligible" do
              expect(overall_result).to eq(:eligible)
            end
          end

          context "when applicant over 18", :vcr do
            let(:date_of_birth) { "2000-02-02" }
            let(:params) { proceeding_types }

            it "is not eligible" do
              expect(overall_result).not_to eq(:eligible)
            end
          end
        end
      end
    end
  end
end
