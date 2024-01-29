require "rails_helper"

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, :calls_lfa, type: :request do
    describe "POST /create" do
      let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
      let(:employed) { false }
      let(:log_record) { RequestLog.last }
      let(:date_of_birth) { "1992-07-22" }
      let(:client_id) { "347b707b-d795-47c2-8b39-ccf022eae33b" }
      let(:user_agent) { Faker::ProgrammingLanguage.name }
      let(:current_date) { Date.new(2022, 6, 6).to_s }
      let(:submission_date_params) { { submission_date: current_date } }
      let(:default_params) do
        {
          assessment: submission_date_params,
          applicant: { date_of_birth: "2001-02-02",
                       has_partner_opponent: false,
                       receives_qualifying_benefit: false,
                       employed: },
          proceeding_types: [{ ccms_code: "DA001", client_involvement_type: "A" }],
        }
      end

      let(:partner_employments) do
        [
          {
            name: "Job 1",
            client_id: SecureRandom.uuid,
            receiving_only_statutory_sick_or_maternity_pay: true,
            payments: %w[2022-03-30 2022-04-30 2022-05-30].map do |date|
              {
                client_id: SecureRandom.uuid,
                gross: 846.00,
                benefits_in_kind: 16.60,
                tax: -104.10,
                national_insurance: -18.66,
                date:,
              }
            end,
          },
        ]
      end

      let(:vehicle_params) do
        [
          attributes_for(:vehicle, value: 2638.69, loan_amount_outstanding: 3907.77,
                                   date_of_purchase: "2022-03-05", in_regular_use: false),
          attributes_for(:vehicle, value: 4238.39, loan_amount_outstanding: 6139.36,
                                   date_of_purchase: "2021-09-23", in_regular_use: true),
        ]
      end
      let(:properties_params) do
        [
          {
            value: 1000,
            outstanding_mortgage: 0,
            percentage_owned: 99,
            shared_with_housing_assoc: false,
          },
          {
            value: 10_000,
            outstanding_mortgage: 40,
            percentage_owned: 80,
            shared_with_housing_assoc: true,
          },
        ]
      end

      before do
        post v6_assessments_path, params: default_params.merge(params).to_json, headers:
      end

      context "with top level schema error" do
        context "invalid additional attribute for top level" do
          let(:params) { { additional_attribute: "additional_attribute" } }

          it "returns error JSON for '#/'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/' contains additional properties})
          end
        end
      end

      context "with an invalid submission date", :errors do
        let(:current_date) { "frobulate" }
        let(:params) { {} }

        it "has a correct error status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns an error" do
          expect(parsed_response[:errors]).to eq(["Submission date can't be blank"])
        end
      end

      context "with a property error" do
        context "invalid additional attribute for properties" do
          let(:params) do
            {
              properties: {
                additional_attribute: "additional_attribute",
                main_home: properties_params.first,
                additional_properties: properties_params,
              },
            }
          end

          it "returns error JSON for '#/properties'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/properties' contains additional properties})
          end
        end

        context "invalid additional attribute for properties.main_home" do
          let(:params) do
            {
              properties: {
                main_home: properties_params.first.merge(additional_attribute: "additional_attribute"),
                additional_properties: properties_params,
              },
            }
          end

          it "returns error JSON for '#/properties/main_home'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/properties/main_home' contains additional properties})
          end
        end

        context "invalid additional attribute for properties.additional_properties" do
          let(:params) do
            {
              properties: {
                main_home: properties_params.first,
                additional_properties: properties_params.map { |p| p.merge(additional_attribute: "additional_attribute") },
              },
            }
          end

          it "returns error JSON for '#/properties/additional_properties/0'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/properties/additional_properties/0' contains additional properties})
          end
        end
      end

      context "with vehicles error" do
        context "invalid additional attribute for vehicles" do
          let(:params) { { vehicles: vehicle_params.map { |v| v.merge(additional_attribute: "additional_attribute") } } }

          it "returns error JSON for '#/vehicles/0'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/vehicles/0' contains additional properties})
          end
        end
      end

      context "with proceeding type error" do
        context "with an invalid additional attribute for proceeding_types" do
          let(:params) { { proceeding_types: [attributes_for(:proceeding_type).merge!(additional_attribute: "additional_attribute")] } }

          it "returns error JSON for '#/proceeding_types/0'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/proceeding_types/0' contains additional properties})
          end
        end
      end

      context "with a partner error" do
        context "invalid additional attribute for partner" do
          let(:params) do
            { partner: { partner: { employed: true, date_of_birth: }, additional_attribute: "additional_attribute" } }
          end

          it "returns error JSON for '#/partner'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/partner' contains additional properties})
          end
        end

        context "invalid additional attribute for partner.partner" do
          let(:params) do
            { partner: { partner: { employed: true, date_of_birth:, additional_attribute: "additional_attribute" } } }
          end

          it "returns error JSON for '#/partner/partner'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/partner/partner' contains additional properties})
          end
        end

        context "with invalid partner outgoings" do
          let(:params) do
            {
              partner: {
                partner: { employed: true, date_of_birth: },
                outgoings: [
                  {
                    name: "child_care",
                    payments: [
                      {
                        payment_date: "2090-01-01",
                        amount: 29.12,
                        client_id: SecureRandom.uuid,
                      },
                    ],
                  },
                ],
              },
            }
          end

          it "errors" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "contains the error" do
            expect(parsed_response).to eq({ success: false, errors: ["Payment date cannot be in the future"] })
          end
        end

        context "invalid additional attribute for partner.employments" do
          let(:params) do
            {
              partner: {
                partner: { employed: true, date_of_birth: },
                employments: [
                  {
                    name: "A",
                    client_id: "B",
                    additional_attribute: "additional_attribute",
                    payments: [],
                  },
                ],
              },
            }
          end

          it "returns error JSON for '#/partner/employments/0'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/partner/employments/0' contains additional properties})
          end
        end

        context "validate 'receiving_only_statutory_sick_or_maternity_pay' for partner.employments" do
          let(:params) do
            {
              partner: {
                partner: { date_of_birth: "1987-08-08", employed: true },
                employments: partner_employments,
              },
            }
          end

          it "returns http success" do
            expect(parsed_response[:errors]).to be_nil
            expect(response).to have_http_status(:success)
          end
        end

        context "missing partner" do
          let(:params) do
            { partner: {} }
          end

          it "returns error" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/partner' did not contain a required property of 'partner'})
          end
        end

        context "missing partner date_of_birth" do
          let(:params) do
            { partner: { partner: { employed: true } } }
          end

          it "returns error" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/partner/partner' did not contain a required property of 'date_of_birth'})
          end
        end

        context "invalid partner date_of_birth" do
          let(:params) do
            {
              partner: {
                partner: { date_of_birth: "2087-08-08", employed: true },
              },
            }
          end

          it "errors" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "contains the error" do
            expect(parsed_response).to eq({ success: false, errors: ["Date of birth cannot be in the future"] })
          end
        end
      end

      context "with an explicit remarks error" do
        context "invalid additional attribute for explicit_remarks" do
          let(:params) do
            {
              explicit_remarks: [
                {
                  category: "policy_disregards",
                  details: %w[employment charity],
                  additional_attribute: "additional_attribute",
                },
              ],
            }
          end

          it "returns error JSON for '#/explicit_remarks/0'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/explicit_remarks/0' contains additional properties})
          end
        end
      end

      xcontext "with invalid cash_transactions" do
        context "invalid additional attribute for cash_transactions" do
          let(:params) { { cash_transactions: { income: [], outgoings: [], additional_attribute: "additional_attribute" } } }

          it "returns error JSON for '#/cash_transactions'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/cash_transactions' contains additional properties})
          end
        end

        context "with payments on incorrect dates" do
          let(:params) do
            {
              cash_transactions: {
                income: [],
                outgoings: [
                  { category: "maintenance_out",
                    payments: [
                      {
                        date: "2022-02-06",
                        amount: 256,
                        client_id:,
                      },
                      {
                        date: "2022-03-01",
                        amount: 256,
                        client_id:,
                      },
                      {
                        date: "2022-04-01",
                        amount: 256,
                        client_id:,
                      },
                    ] },
                ],
              },
            }
          end

          it "returns error JSON for '#/cash_transactions/outgoings/0/payments/0'" do
            expect(parsed_response[:errors]).to eq ["Expecting payment dates for category maintenance_out to be 1st of three of the previous 3 months"]
          end
        end

        context "with an invalid payment date" do
          let(:params) do
            {
              cash_transactions: {
                income: [],
                outgoings: [
                  { category: "maintenance_out",
                    payments: [
                      {
                        date: "2022-22-06",
                        amount: 256,
                        client_id:,
                      },
                      {
                        date: "2022-03-01",
                        amount: 256,
                        client_id:,
                      },
                      {
                        date: "2022-04-01",
                        amount: 256,
                        client_id:,
                      },
                    ] },
                ],
              },
            }
          end

          it "doesnt crash" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error JSON for '#/cash_transactions/outgoings/0/payments/0'" do
            expect(parsed_response).to eq({ success: false, errors: ["Expecting payment dates for category maintenance_out to be 1st of three of the previous 3 months"] })
          end
        end

        context "with invalid income property" do
          let(:params) { { cash_transactions: { income: {}, outgoings: [] } } }

          it "returns error" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error JSON" do
            expect(parsed_response[:errors])
              .to include(/The property '#\/cash_transactions\/income' of type object did not match the following type: array in schema/)
          end
        end
      end

      context "with invalid irregular incomes" do
        context "invalid additional attribute for irregular_incomes" do
          let(:params) do
            {
              irregular_incomes: {
                additional_attribute: "additional_attribute",
                payments: [{ income_type: "student_loan", frequency: "annual", amount: 123_456.78 }],
              },
            }
          end

          it "returns error JSON for '#/irregular_incomes'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/irregular_incomes' contains additional properties})
          end
        end
      end

      context "with invalid other incomes" do
        let(:payment) { { date: "2022-02-27", amount: 256, client_id: } }
        let(:params) do
          {
            other_incomes: [{
              source: "benefits",
              additional_attribute: "additional_attribute",
              payments: [payment],
            }],
          }
        end

        it "returns error JSON for '#/other_incomes/0'" do
          expect(parsed_response[:errors]).to include(%r{The property '#/other_incomes/0' contains additional properties})
        end

        context "invalid additional attribute for other_incomes.payments" do
          let(:params) do
            {
              other_incomes: [{
                source: "benefits",
                payments: [payment.merge(additional_attribute: "additional_attribute")],
              }],
            }
          end

          it "returns error JSON for '#other_incomes/0/payments/0'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/other_incomes/0/payments/0' contains additional properties})
          end
        end
      end

      context "with an assessment error" do
        let(:params) { { assessment: { client_reference_id: "3000-01-01" } } }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          expect(parsed_response[:errors]).to include(%r{The property '#/assessment' did not contain a required property of 'submission_date'})
        end
      end

      context "with an invalid proceeding type" do
        let(:params) { { proceeding_types: [{ ccms_code: "ZZ", client_involvement_type: "A" }] } }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          codes = CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES.join(", ")
          expect(parsed_response[:errors])
            .to include(/The property '#\/proceeding_types\/0\/ccms_code' value "ZZ" did not match one of the following values: #{codes} in schema/)
        end
      end

      context "with no proceeding types" do
        let(:params) { { proceeding_types: [] } }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          expect(parsed_response[:errors])
            .to include(/The property '#\/proceeding_types' did not contain a minimum number of items 1 in schema/)
        end
      end

      context "with no applicant" do
        let(:default_params) { { assessment: {} } }
        let(:params) { {} }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          expect(parsed_response[:errors]).to include(%r{The property '#/' did not contain a required property of 'applicant'})
        end
      end

      context "with an applicant error" do
        context "missing date_of_birth" do
          let(:params) do
            { applicant: { has_partner_opponent: false,
                           receives_qualifying_benefit: false,
                           employed: } }
          end

          it "returns error" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/applicant' did not contain a required property of 'date_of_birth'})
          end
        end

        context "with a future date of birth", :errors do
          let(:params) do
            { applicant: { has_partner_opponent: false,
                           receives_qualifying_benefit: false,
                           date_of_birth: "2900-01-09",
                           employed: } }
          end

          it "returns error" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(/Date of birth cannot be in the future/)
          end

          it "creates a log record" do
            expect(log_record)
              .to have_attributes(created_at: Time.zone.today,
                                  http_status: 422,
                                  response: {
                                    "success" => false,
                                    "errors" => ["Date of birth cannot be in the future"],
                                  })
            expect(log_record.request.except("applicant")).to eq({
              "assessment" => { "submission_date" => "2022-06-06" },
              "proceeding_types" => [{ "ccms_code" => "DA001", "client_involvement_type" => "A" }],
            })
          end
        end
      end

      context "with a dependant error" do
        context "invalid additional attribute for dependants" do
          let(:params) do
            {
              dependants: [
                attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, monthly_income: 0, date_of_birth: "3004-06-11", additional_attribute: "additional_attribute"),
              ],
            }
          end

          it "returns error JSON for '#/dependants/0'" do
            expect(parsed_response[:errors]).to include(%r{The property '#/dependants/0' contains additional properties})
          end
        end

        context "with a future date of birth" do
          let(:params) do
            { dependants: [
              attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, income: { amount: 0, frequency: "monthly" }, date_of_birth: "3004-06-11").except(:income_amount, :income_frequency),
            ] }
          end

          it "returns error" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error JSON" do
            expect(parsed_response[:errors])
              .to include(/Date of birth cannot be in the future/)
          end
        end

        context "missing dependant date_of_birth" do
          let(:params) do
            { dependants: [
              attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, income: { amount: 0, frequency: "monthly" }).except(:date_of_birth, :income_amount, :income_frequency),
            ] }
          end

          it "returns error" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/dependants/0' did not contain a required property of 'date_of_birth'})
          end
        end
      end

      context "with a partner dependant error" do
        context "with a future date of birth" do
          let(:params) do
            {
              partner: { partner: attributes_for(:applicant).except(:receives_qualifying_benefit, :receives_asylum_support),
                         dependants: [
                           attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, income: { amount: 0, frequency: "monthly" }, date_of_birth: "2904-06-11").except(:income_amount, :income_frequency),
                         ] },
            }
          end

          it "returns error" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error JSON" do
            expect(parsed_response[:errors])
              .to include(/Date of birth cannot be in the future/)
          end
        end

        context "with missing date of birth" do
          let(:params) do
            {
              partner: { partner: attributes_for(:applicant),
                         dependants: [
                           attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, income: { amount: 0, frequency: "monthly" }, date_of_birth: "2904-06-11").except(:date_of_birth, :income_amount, :income_frequency),
                         ] },
            }
          end

          it "returns error" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/partner/dependants/0' did not contain a required property of 'date_of_birth'})
          end
        end
      end

      context "with invalid outgoings" do
        let(:params) do
          {
            outgoings: [
              {
                name: "child_care",
                payments: [
                  {
                    payment_date: "2090-01-01",
                    amount: 29.12,
                    client_id: SecureRandom.uuid,
                  },
                ],
              },
            ],
          }
        end

        it "errors" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "contains the error" do
          expect(parsed_response).to eq({ success: false, errors: ["Payment date cannot be in the future"] })
        end
      end
    end
  end
end
