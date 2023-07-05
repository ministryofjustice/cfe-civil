require "rails_helper"

module V7
  RSpec.describe AssessmentsController, :calls_bank_holiday, type: :request do
    describe "POST /create" do
      let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
      let(:employed) { false }
      let(:user_agent) { Faker::ProgrammingLanguage.name }
      let(:current_date) { Date.new(2022, 6, 6) }
      let(:submission_date_params) { { submission_date: current_date.to_s } }
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
        post v7_assessments_path, params: default_params.merge(params).to_json, headers:
      end

      context "with top level schema error" do
        context "invalid additional attribute for top level" do
          let(:params) { { additional_attribute: "additional_attribute" } }

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/' contains additional properties})
          end
        end
      end

      context "with an property error" do
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

          it "returns error JSON" do
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

          it "returns error JSON" do
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

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/properties/additional_properties/0' contains additional properties})
          end
        end
      end

      context "with vehicles error" do
        context "invalid additional attribute for vehicles" do
          let(:params) { { vehicles: vehicle_params.map { |v| v.merge(additional_attribute: "additional_attribute") } } }

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/vehicles/0' contains additional properties})
          end
        end
      end

      context "with proceeding type error" do
        context "with an invalid additional attribute for proceeding_types" do
          let(:params) { { proceeding_types: [attributes_for(:proceeding_type).merge!(additional_attribute: "additional_attribute")] } }

          it "returns error JSON" do
            expect(parsed_response[:errors])
              .to include(/The property '#\/proceeding_types\/0' contains additional properties/)
          end
        end
      end

      context "with an partner error" do
        context "invalid additional attribute for partner" do
          let(:params) do
            { partner: { partner: { employed: true, date_of_birth: "1992-07-22" }, additional_attribute: "additional_attribute" } }
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/partner' contains additional properties})
          end
        end

        context "invalid additional attribute for partner.partner" do
          let(:params) do
            { partner: { partner: { employed: true, date_of_birth: "1992-07-22", additional_attribute: "additional_attribute" } } }
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/partner/partner' contains additional properties})
          end
        end

        context "invalid additional attribute for partner.employments" do
          let(:params) do
            {
              partner: {
                partner: { employed: true, date_of_birth: "1992-07-22" },
                employments: [
                  {
                    name: "A",
                    client_id: "B",
                    additional_attribute: "additional_attribute",
                    payments: [attributes_for(:employment_payment)],
                  },
                ],
              },
            }
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/partner/employments/0' contains additional properties})
          end
        end
      end

      context "with an dependant error" do
        context "invalid additional attribute for dependants" do
          let(:params) do
            {
              dependants: [
                attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, monthly_income: 0, date_of_birth: "3004-06-11", additional_attribute: "additional_attribute"),
              ],
            }
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/dependants/0' contains additional properties})
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

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(%r{The property '#/explicit_remarks/0' contains additional properties})
          end
        end
      end

      context "with invalid cash_transactions" do
        context "invalid additional attribute for cash_transactions" do
          let(:params) { { cash_transactions: { income: [], outgoings: [], additional_attribute: "additional_attribute" } } }

          it "returns error JSON" do
            expect(parsed_response[:errors])
              .to include(/The property '#\/cash_transactions' contains additional properties/)
          end
        end

        context "invalid additional property for cash_transactions.outgoings.payments" do
          let(:params) do
            {
              cash_transactions: {
                income: [],
                outgoings: [
                  { category: "maintenance_out",
                    payments: [
                      {
                        date: "2022-02-01",
                        amount: 256,
                        client_id: "347b707b-d795-47c2-8b39-ccf022eae33b",
                        additional_attribute: "additional_attribute",
                      },
                      {
                        date: "2022-03-01",
                        amount: 256,
                        client_id: "347b707b-d795-47c2-8b39-ccf022eae33b",
                        additional_attribute: "additional_attribute",
                      },
                      {
                        date: "2022-04-01",
                        amount: 256,
                        client_id: "347b707b-d795-47c2-8b39-ccf022eae33b",
                        additional_attribute: "additional_attribute",
                      },
                    ] },
                ],
              },
            }
          end

          it "returns error JSON" do
            expect(parsed_response[:errors])
              .to include(/The property '#\/cash_transactions\/outgoings\/0\/payments\/0' contains additional properties/)
          end
        end
      end

      context "with an invalid irregular incomes" do
        context "invalid additional attribute for irregular_incomes" do
          let(:params) do
            {
              irregular_incomes: {
                additional_attribute: "additional_attribute",
                payments: [{ income_type: "student_loan", frequency: "annual", amount: 123_456.78 }],
              },
            }
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(/The property '#\/irregular_incomes' contains additional properties/)
          end
        end
      end

      context "with an invalid other incomes" do
        let(:params) do
          {
            other_incomes: [{
              source: "benefits",
              additional_attribute: "additional_attribute",
              payments: [{
                date: "2022-02-01",
                amount: 256,
                client_id: "347b707b-d795-47c2-8b39-ccf022eae33b",
              }],
            }],
          }
        end

        it "returns error JSON" do
          expect(parsed_response[:errors]).to include(/The property '#\/other_incomes\/0' contains additional properties/)
        end

        context "invalid additional attribute for other_incomes.payments" do
          let(:params) do
            {
              other_incomes: [{
                source: "benefits",
                payments: [{
                  date: "2022-02-01",
                  amount: 256,
                  client_id: "347b707b-d795-47c2-8b39-ccf022eae33b",
                  additional_attribute: "additional_attribute",
                }],
              }],
            }
          end

          it "returns error JSON" do
            expect(parsed_response[:errors]).to include(/The property '#\/other_incomes\/0\/payments\/0' contains additional properties/)
          end
        end
      end
    end
  end
end
