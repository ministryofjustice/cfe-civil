require "rails_helper"

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, :calls_lfa, type: :request do
    describe "POST /create" do
      let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
      let(:assessment) { parsed_response.fetch(:assessment).except(:id) }
      let(:employed) { false }
      let(:user_agent) { Faker::ProgrammingLanguage.name }
      let(:log_record) { RequestLog.last }
      let(:current_date) { Date.new(2022, 6, 6) }
      let(:submission_date_params) { { submission_date: current_date.to_s } }
      let(:second_month) { current_date.beginning_of_month - 3.months }
      let(:third_month) { current_date.beginning_of_month - 2.months }
      let(:fourth_month) { current_date.beginning_of_month - 1.month }
      let(:dob) { "2001-02-02" }
      let(:redacted_message) { CFEConstants::REDACTED_MESSAGE }
      let(:client_ref) { "3000-01-01" }
      let(:default_params) do
        {
          assessment: submission_date_params,
          applicant: { date_of_birth: dob,
                       has_partner_opponent: false,
                       receives_qualifying_benefit: false,
                       employed: },
          proceeding_types: [{ ccms_code: "DA001", client_involvement_type: "A" }],
        }
      end
      let(:cash_transactions_params) do
        {
          income: [
            { category: "maintenance_in", payments: cash_transactions(1033.44) },
            { category: "friends_or_family", payments: cash_transactions(250.0) },
            { category: "benefits", payments: cash_transactions(65.12) },
            { category: "property_or_lodger", payments: cash_transactions(91.87) },
            { category: "pension", payments: cash_transactions(34.12) },
          ],
          outgoings: [
            { category: "maintenance_out", payments: cash_transactions(256.0) },
            { category: "child_care", payments: cash_transactions(257.0) },
            { category: "legal_aid", payments: cash_transactions(44.54) },
            { category: "rent_or_mortgage", payments: cash_transactions(87.54) },
            { category: "pension_contribution", payments: cash_transactions(87.54) },
          ],
        }
      end
      let(:employment_payment_dates) { %w[2022-03-30 2022-04-30 2022-05-30] }
      let(:employment_income_params) do
        [
          {
            name: "Job 1",
            client_id: SecureRandom.uuid,
            payments: employment_payment_dates.map do |date|
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
      let(:employment_income_without_payments_params) do
        [
          {
            name: "Job 1",
            client_id: SecureRandom.uuid,
            payments: [],
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
            subject_matter_of_dispute: false,
          },
          {
            value: 10_000,
            outstanding_mortgage: 40,
            percentage_owned: 80,
            shared_with_housing_assoc: true,
            subject_matter_of_dispute: false,
          },
        ]
      end
      let(:dependant_params_with_monthly_income) do
        [
          attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, monthly_income: 0, date_of_birth: "2015-02-11").except(:income_amount, :income_frequency),
          attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, monthly_income: 0, date_of_birth: "2013-06-11").except(:income_amount, :income_frequency),
          attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, monthly_income: 0, date_of_birth: "2004-06-11").except(:income_amount, :income_frequency),
        ]
      end
      let(:dependant_params) do
        [
          attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, income: { amount: 400, frequency: "monthly" }, date_of_birth: "2015-02-11").except(:income_amount, :income_frequency),
          attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, income: { amount: 0, frequency: "monthly" }, date_of_birth: "2013-06-11").except(:income_amount, :income_frequency),
          attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, income: { amount: 400, frequency: "monthly" }, date_of_birth: "2004-06-11").except(:income_amount, :income_frequency),
        ]
      end
      let(:first_bank_account) { "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}" }
      let(:second_bank_account) { "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}" }
      let(:bank_account_params) do
        [
          {
            description: first_bank_account,
            value: 28.34,
          },
          {
            description: second_bank_account,
            value: 67.23,
          },
        ]
      end
      let(:first_asset) { "R.J.Ewing Trust" }
      let(:second_asset) { "Ming Vase" }
      let(:non_liquid_params) do
        [
          { description: first_asset, value: 17.12 },
          { description: second_asset, value: 6.19 },
        ]
      end
      let(:irregular_income_payments) do
        [
          { income_type: "student_loan", frequency: "annual", amount: 456.78 },
          { income_type: "unspecified_source", frequency: "monthly", amount: 10.92 },
        ]
      end
      let(:irregular_income_params) { { payments: irregular_income_payments } }

      before do
        post v6_assessments_path, params: default_params.merge(params).to_json, headers:
      end

      context "with blank main and additional homes" do
        let(:params) do
          {
            employment_income: [
              {
                name: "Job 1",
                client_id: "xxx",
                payments: [
                  {
                    client_id: "yyy",
                    date: "2023-01-31",
                    gross: 2024.0,
                    tax: -194.2,
                    national_insurance: -117.12,
                  },
                  {
                    client_id: "zzz",
                    date: "2022-12-31",
                    gross: 1936.0,
                    tax: -176.6,
                    national_insurance: -106.56,
                  },
                  {
                    client_id: "www",
                    date: "2022-12-01",
                    gross: 1848.0,
                    tax: -158.8,
                    national_insurance: -96.0,
                  },
                  {
                    client_id: "vvv",
                    date: "2022-10-31",
                    gross: 2024.0,
                    tax: -194.2,
                    national_insurance: -129.32,
                  },
                ].map { _1.merge(benefits_in_kind: 0) },
              },
            ],
            properties: {
              main_home: { value: 0.0, outstanding_mortgage: 0.0, percentage_owned: 0.0, shared_with_housing_assoc: false },

              additional_properties: [
                {
                  value: 0.0,
                  outstanding_mortgage: 0.0,
                  percentage_owned: 0.0,
                  shared_with_housing_assoc: false,
                  subject_matter_of_dispute: true,
                },
              ],
            },
          }
        end

        it "returns the correct (empty) result" do
          expect(parsed_response.dig(:assessment, :capital, :capital_items, :properties))
            .to eq(
              {
                main_home: {
                  value: 0.0,
                  outstanding_mortgage: 0.0,
                  percentage_owned: 0.0,
                  main_home: true,
                  shared_with_housing_assoc: false,
                  transaction_allowance: 0.0,
                  allowable_outstanding_mortgage: 0.0,
                  net_value: 0.0,
                  net_equity: 0.0,
                  smod_allowance: 0,
                  main_home_equity_disregard: 0.0,
                  assessed_equity: 0.0,
                  subject_matter_of_dispute: nil,
                },
                additional_properties: [
                  {
                    value: 0.0,
                    outstanding_mortgage: 0.0,
                    percentage_owned: 0.0,
                    main_home: false,
                    shared_with_housing_assoc: false,
                    transaction_allowance: 0.0,
                    allowable_outstanding_mortgage: 0.0,
                    net_value: 0.0,
                    net_equity: 0.0,
                    smod_allowance: 0,
                    main_home_equity_disregard: 0.0,
                    assessed_equity: 0.0,
                    subject_matter_of_dispute: true,
                  },
                ],
              },
            )
        end
      end

      context "with an applicant without partner opponent" do
        let(:params) do
          { applicant: { date_of_birth: dob,
                         receives_qualifying_benefit: false,
                         employed: } }
        end

        it "returns false for has_partner_opponent" do
          expect(parsed_response.dig(:assessment, :applicant, :has_partner_opponent)).to be(false)
        end
      end

      context "with dependants" do
        context "with no income for dependants" do
          let(:params) { { dependants: dependant_params.map { _1.except(:income) } } }

          it "creates a log record" do
            expect(parsed_response.dig(:result_summary, :disposable_income)).to include(dependant_allowance_under_16: 615.28, dependant_allowance_over_16: 307.64)
          end
        end

        context "with 'monthly_income' for dependants" do
          let(:params) { { dependants: dependant_params_with_monthly_income.map { _1.merge(monthly_income: 400) } } }

          it "returns the dependant allowance result" do
            expect(parsed_response.dig(:result_summary, :disposable_income)).to include(dependant_allowance_under_16: 0, dependant_allowance_over_16: 0)
          end
        end

        context "with 'income' for dependants" do
          context "monthly frequency" do
            context "monthly income below the allowance threshold" do
              let(:params) { { dependants: dependant_params.map { _1.merge(income: { amount: 200, frequency: "monthly" }) } } }

              it "returns the dependant allowance result" do
                expect(parsed_response.dig(:result_summary, :disposable_income)).to include(dependant_allowance_under_16: 215.28, dependant_allowance_over_16: 107.64)
              end
            end

            context "monthly income above the allowance threshold" do
              let(:params) { { dependants: dependant_params.map { _1.merge(income: { amount: 400, frequency: "monthly" }) } } }

              it "returns the dependant allowance result" do
                expect(parsed_response.dig(:result_summary, :disposable_income)).to include(dependant_allowance_under_16: 0, dependant_allowance_over_16: 0)
              end
            end
          end

          context "weekly frequency" do
            let(:params) { { dependants: dependant_params.map { _1.merge(income: { amount: 400, frequency: "weekly" }) } } }

            it "returns the dependant allowance result" do
              expect(parsed_response.dig(:result_summary, :disposable_income)).to include(dependant_allowance_under_16: 0, dependant_allowance_over_16: 0)
            end
          end
        end
      end

      context "with explicit remarks (needs to be contribution required to show in response)" do
        let(:params) do
          {
            capitals: { bank_accounts: attributes_for_list(:non_liquid_capital_item, 1, value: 20_000.0) },
            explicit_remarks: [
              {
                category: "policy_disregards",
                details: %w[employment charity],
              },
            ],
          }
        end

        it "is contribution_required" do
          expect(parsed_response.dig(:result_summary, :overall_result, :result)).to eq("contribution_required")
        end

        it "has remarks" do
          expect(parsed_response.dig(:assessment, :remarks)).to eq({ policy_disregards: %w[charity employment] })
        end
      end

      context "with cash transactions" do
        let(:params) do
          {
            # child_care won't show up unless student loan payments and dependants
            irregular_incomes: irregular_income_params,
            dependants: dependant_params_with_monthly_income,
            cash_transactions: cash_transactions_params,
          }
        end
        let(:cash_transaction_log) { log_record.request.deep_symbolize_keys.fetch(:cash_transactions) }

        it "has 2 keys" do
          expect(cash_transaction_log.keys).to match_array(%i[income outgoings])
        end

        it "redacts income client_ids" do
          expect(cash_transaction_log.fetch(:income))
            .to contain_exactly({ category: "maintenance_in",
                                  payments: [{ date: third_month.to_s, amount: 1033.44, client_id: redacted_message },
                                             { date: fourth_month.to_s, amount: 1033.44, client_id: redacted_message },
                                             { date: second_month.to_s, amount: 1033.44, client_id: redacted_message }] }, { category: "friends_or_family",
                                                                                                                             payments: [{ date: third_month.to_s, amount: 250.0, client_id: redacted_message },
                                                                                                                                        { date: fourth_month.to_s, amount: 250.0, client_id: redacted_message },
                                                                                                                                        { date: second_month.to_s, amount: 250.0, client_id: redacted_message }] }, { category: "benefits",
                                                                                                                                                                                                                      payments: [{ date: third_month.to_s, amount: 65.12, client_id: redacted_message },
                                                                                                                                                                                                                                 { date: fourth_month.to_s, amount: 65.12, client_id: redacted_message },
                                                                                                                                                                                                                                 { date: second_month.to_s, amount: 65.12, client_id: redacted_message }] }, { category: "property_or_lodger",
                                                                                                                                                                                                                                                                                                               payments: [{ date: third_month.to_s, amount: 91.87, client_id: redacted_message },
                                                                                                                                                                                                                                                                                                                          { date: fourth_month.to_s, amount: 91.87, client_id: redacted_message },
                                                                                                                                                                                                                                                                                                                          { date: second_month.to_s, amount: 91.87, client_id: redacted_message }] }, { category: "pension",
                                                                                                                                                                                                                                                                                                                                                                                                        payments: [{ date: third_month.to_s, amount: 34.12, client_id: redacted_message },
                                                                                                                                                                                                                                                                                                                                                                                                                   { date: fourth_month.to_s, amount: 34.12, client_id: redacted_message },
                                                                                                                                                                                                                                                                                                                                                                                                                   { date: second_month.to_s, amount: 34.12, client_id: redacted_message }] })
        end

        it "redacts outgoings client ids in the log" do
          expect(cash_transaction_log.fetch(:outgoings))
            .to eq(
              [{ category: "maintenance_out",
                 payments: [{ date: third_month.to_s, amount: 256.0, client_id: redacted_message },
                            { date: fourth_month.to_s, amount: 256.0, client_id: redacted_message },
                            { date: second_month.to_s, amount: 256.0, client_id: redacted_message }] },
               { category: "child_care",
                 payments: [{ date: third_month.to_s, amount: 257.0, client_id: redacted_message },
                            { date: fourth_month.to_s, amount: 257.0, client_id: redacted_message },
                            { date: second_month.to_s, amount: 257.0, client_id: redacted_message }] },
               { category: "legal_aid",
                 payments: [{ date: third_month.to_s, amount: 44.54, client_id: redacted_message },
                            { date: fourth_month.to_s, amount: 44.54, client_id: redacted_message },
                            { date: second_month.to_s, amount: 44.54, client_id: redacted_message }] },
               { category: "rent_or_mortgage",
                 payments: [{ date: third_month.to_s, amount: 87.54, client_id: redacted_message },
                            { date: fourth_month.to_s, amount: 87.54, client_id: redacted_message },
                            { date: second_month.to_s, amount: 87.54, client_id: redacted_message }] },
               { category: "pension_contribution",
                 payments: [{ date: third_month.to_s, amount: 87.54, client_id: redacted_message },
                            { date: fourth_month.to_s, amount: 87.54, client_id: redacted_message },
                            { date: second_month.to_s, amount: 87.54, client_id: redacted_message }] }],
            )
        end

        it "has other_income" do
          expect(assessment.dig(:gross_income, :other_income, :monthly_equivalents))
            .to eq(
              {
                all_sources: { friends_or_family: 250.0, maintenance_in: 1033.44, property_or_lodger: 91.87, pension: 34.12 },
                bank_transactions: { friends_or_family: 0.0, maintenance_in: 0.0, property_or_lodger: 0.0, pension: 0.0 },
                cash_transactions: { friends_or_family: 250.0, maintenance_in: 1033.44, property_or_lodger: 91.87, pension: 34.12 },
              },
            )
        end

        it "has disposable income" do
          expect(assessment.dig(:disposable_income, :monthly_equivalents))
            .to eq(
              {
                all_sources: { child_care: 257.0, rent_or_mortgage: 87.54, maintenance_out: 256.0, legal_aid: 44.54, pension_contribution: 0.0, council_tax: 0.0, priority_debt_repayment: 0.0 },
                bank_transactions: { child_care: 0.0, rent_or_mortgage: 0.0, maintenance_out: 0.0, legal_aid: 0.0, pension_contribution: 0.0, council_tax: 0.0, priority_debt_repayment: 0.0 },
                cash_transactions: { child_care: 257.0, rent_or_mortgage: 87.54, maintenance_out: 256.0, legal_aid: 44.54, pension_contribution: 0.0, council_tax: 0.0, priority_debt_repayment: 0.0 },
              },
            )
        end
      end

      def cash_transactions(amount)
        [third_month, fourth_month, second_month].map do |p|
          {
            date: p.strftime("%F"),
            amount:,
            client_id: SecureRandom.uuid,
          }
        end
      end

      context "with capital values as strings" do
        let(:capital_items) { assessment.fetch(:capital).fetch(:capital_items) }

        let(:params) do
          {
            capitals: {
              bank_accounts: [
                {
                  description: first_bank_account,
                  value: "28.34",
                },
              ],
              non_liquid_capital: [
                {
                  description: first_asset,
                  value: 17.12,
                },
              ],
            },
          }
        end

        it "has liquid" do
          expect(capital_items.fetch(:liquid))
            .to contain_exactly({ description: first_bank_account, value: 28.34 })
        end

        it "has non_liquid" do
          expect(capital_items.fetch(:non_liquid))
            .to contain_exactly({ description: "R.J.Ewing Trust", value: 17.12 })
        end
      end

      context "with capitals" do
        let(:params) do
          {
            capitals: {
              bank_accounts: bank_account_params,
              non_liquid_capital: non_liquid_params,
            },
          }
        end

        describe "capital items" do
          let(:capital_items) { assessment.fetch(:capital).fetch(:capital_items) }

          it "has liquid" do
            expect(capital_items.fetch(:liquid))
              .to contain_exactly({ description: first_bank_account, value: 28.34 }, { description: second_bank_account, value: 67.23 })
          end

          it "has non_liquid" do
            expect(capital_items.fetch(:non_liquid))
              .to contain_exactly({ description: "R.J.Ewing Trust", value: 17.12 }, { description: "Ming Vase", value: 6.19 })
          end
        end
      end

      context "with employment income" do
        let(:employed) { true }
        let(:params) { { employment_income: employment_income_params } }

        describe "disposable_income from summary" do
          let(:employment_income) { parsed_response.dig(:result_summary, :disposable_income, :employment_income) }

          it "has employment income" do
            expect(employment_income)
              .to eq(
                {
                  gross_income: 846.0,
                  benefits_in_kind: 16.6,
                  tax: -104.1,
                  national_insurance: -18.66,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  fixed_employment_deduction: -45.0,
                  net_employment_income: 694.84,
                },
              )
          end
        end

        context "with negative tax and NICs" do
          let(:disposable_employment_income) { parsed_response.dig(:result_summary, :disposable_income, :employment_income) }
          let(:gross_employment_income_payments) { assessment.dig(:gross_income, :employment_income).map { |x| x.fetch(:payments) } }

          context "with one job" do
            let(:employment_income_params) do
              [
                {
                  name: "Job 1",
                  client_id: SecureRandom.uuid,
                  payments: employment_payment_dates.map do |date|
                    {
                      client_id: SecureRandom.uuid,
                      gross: 846.00,
                      benefits_in_kind: 16.60,
                      tax: 48.22,
                      national_insurance: 12.73,
                      date:,
                    }
                  end,
                },
              ]
            end

            it "keeps the correct income values in disposable" do
              expect(disposable_employment_income)
                .to eq(
                  {
                    gross_income: 846.0,
                    benefits_in_kind: 16.6,
                    tax: 48.22,
                    national_insurance: 12.73,
                    prisoner_levy: 0.0,
                    student_debt_repayment: 0.0,
                    fixed_employment_deduction: -45.0,
                    net_employment_income: 878.55,
                  },
                )
            end

            it "zeroes the tax and NICs in gross income" do
              expect(gross_employment_income_payments.first)
                .to contain_exactly({
                  date: "2022-05-30",
                  gross: 846.0,
                  benefits_in_kind: 16.6,
                  tax: 0.0,
                  national_insurance: 0.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 862.6,
                }, {
                  date: "2022-04-30",
                  gross: 846.0,
                  benefits_in_kind: 16.6,
                  tax: 0.0,
                  national_insurance: 0.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 862.6,
                }, {
                  date: "2022-03-30",
                  gross: 846.0,
                  benefits_in_kind: 16.6,
                  tax: 0.0,
                  national_insurance: 0.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 862.6,
                })
            end
          end

          context "with multiple jobs" do
            let(:employment_income_params) do
              [
                {
                  name: "Job 1",
                  client_id: SecureRandom.uuid,
                  payments: employment_payment_dates.map do |date|
                    {
                      client_id: SecureRandom.uuid,
                      gross: 846.00,
                      benefits_in_kind: 16.60,
                      tax: 48.22,
                      national_insurance: 12.73,
                      date:,
                    }
                  end,
                },
                {
                  name: "Job 2",
                  client_id: SecureRandom.uuid,
                  payments: employment_payment_dates.map do |date|
                    {
                      client_id: SecureRandom.uuid,
                      gross: 746.00,
                      benefits_in_kind: 6.60,
                      tax: 38.22,
                      national_insurance: 22.73,
                      date:,
                    }
                  end,
                },
              ]
            end

            it "keeps the correct income values in disposable" do
              expect(disposable_employment_income)
                .to eq(
                  {
                    gross_income: 0.0,
                    benefits_in_kind: 0.0,
                    tax: 0.0,
                    national_insurance: 0.0,
                    prisoner_levy: 0.0,
                    student_debt_repayment: 0.0,
                    fixed_employment_deduction: -45.0,
                    net_employment_income: -45.0,
                  },
                )
            end

            it "zeroes the tax and NICs in gross income" do
              expect(gross_employment_income_payments.flatten)
                .to contain_exactly({
                  date: "2022-05-30",
                  gross: 846.0,
                  benefits_in_kind: 16.6,
                  tax: 0.0,
                  national_insurance: 0.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 862.6,
                }, {
                  date: "2022-04-30",
                  gross: 846.0,
                  benefits_in_kind: 16.6,
                  tax: 0.0,
                  national_insurance: 0.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 862.6,
                }, {
                  date: "2022-03-30",
                  gross: 846.0,
                  benefits_in_kind: 16.6,
                  tax: 0.0,
                  national_insurance: 0.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 862.6,
                }, {
                  date: "2022-05-30",
                  gross: 746.0,
                  benefits_in_kind: 6.6,
                  tax: 0.0,
                  national_insurance: 0.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 752.6,
                }, {
                  date: "2022-04-30",
                  gross: 746.0,
                  benefits_in_kind: 6.6,
                  tax: 0.0,
                  national_insurance: 0.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 752.6,
                }, {
                  date: "2022-03-30",
                  gross: 746.0,
                  benefits_in_kind: 6.6,
                  tax: 0.0,
                  national_insurance: 0.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  net_employment_income: 752.6,
                })
            end
          end
        end

        describe "assessment" do
          describe "gross income" do
            let(:gross_income) { assessment.fetch(:gross_income) }

            it "has employment income" do
              expect(gross_income.fetch(:employment_income)).to eq(
                [
                  {
                    name: "Job 1",
                    payments: [
                      {
                        date: "2022-05-30",
                        gross: 846.0,
                        benefits_in_kind: 16.6,
                        tax: -104.1,
                        national_insurance: -18.66,
                        prisoner_levy: 0.0,
                        student_debt_repayment: 0.0,
                        net_employment_income: 739.84,
                      },
                      {
                        date: "2022-04-30",
                        gross: 846.0,
                        benefits_in_kind: 16.6,
                        tax: -104.1,
                        national_insurance: -18.66,
                        prisoner_levy: 0.0,
                        student_debt_repayment: 0.0,
                        net_employment_income: 739.84,
                      },
                      {
                        date: "2022-03-30",
                        gross: 846.0,
                        benefits_in_kind: 16.6,
                        tax: -104.1,
                        national_insurance: -18.66,
                        prisoner_levy: 0.0,
                        student_debt_repayment: 0.0,
                        net_employment_income: 739.84,
                      },
                    ],
                  },
                ],
              )
            end
          end
        end
      end

      context "with negative gross income" do
        let(:job_with_negative_gross) do
          [
            {
              name: "Job 1",
              client_id: SecureRandom.uuid,
              payments: employment_payment_dates.map do |date|
                {
                  client_id: SecureRandom.uuid,
                  gross: -46.00,
                  benefits_in_kind: 16.60,
                  tax: -104.10,
                  national_insurance: -18.66,
                  date:,
                }
              end,
            },
          ]
        end

        let(:params) { { employment_income: job_with_negative_gross } }

        it "is allowed" do
          expect(response).to have_http_status(:success)
        end
      end

      context "with self employed controlled work" do
        let(:params) do
          {
            assessment: submission_date_params.merge(level_of_help: "controlled"),
            self_employment_details: [{ client_reference: "12345",
                                        income: {
                                          gross: 480,
                                          tax: -263,
                                          national_insurance: -34,
                                          frequency: "monthly",
                                        } }],
            employment_details: [
              { client_reference: "54321",
                income: {
                  receiving_only_statutory_sick_or_maternity_pay: true,
                  gross: 220,
                  benefits_in_kind: 20,
                  tax: -131.50,
                  national_insurance: -17,
                  frequency: "monthly",
                } },
              {
                income: {
                  receiving_only_statutory_sick_or_maternity_pay: true,
                  gross: 220,
                  benefits_in_kind: 20,
                  tax: -131.50,
                  national_insurance: -17,
                  frequency: "monthly",
                },
              },
            ],
          }
        end
        let(:employment_income) { parsed_response.dig(:result_summary, :disposable_income, :employment_income) }
        let(:self_employment_incomes) { parsed_response.dig(:assessment, :gross_income, :self_employment_details) }
        let(:employment_incomes) { parsed_response.dig(:assessment, :gross_income, :employment_details) }

        it "is successful" do
          expect(response).to have_http_status(:success)
        end

        it "has employment income without fixed employment deduction" do
          expect(employment_income)
            .to eq({ gross_income: 920.0,
                     benefits_in_kind: 40.0,
                     fixed_employment_deduction: 0.0,
                     tax: -526.0,
                     prisoner_levy: 0.0,
                     student_debt_repayment: 0.0,
                     national_insurance: -68.0,
                     net_employment_income: 366.0 })
        end

        it "has self employments in the response" do
          expect(self_employment_incomes).to eq([{
            client_reference: "12345",
            monthly_income: {
              gross: 480.0,
              tax: -263.0,
              national_insurance: -34.0,
              prisoner_levy: 0.0,
              student_debt_repayment: 0.0,
              benefits_in_kind: 0.0,
            },
          }])
        end

        it "has employments in the response" do
          expect(employment_incomes).to contain_exactly({ client_reference: "54321",
                                                          monthly_income: {
                                                            gross: 220.0,
                                                            tax: -131.50,
                                                            national_insurance: -17.0,
                                                            prisoner_levy: 0.0,
                                                            student_debt_repayment: 0.0,
                                                            benefits_in_kind: 20.0,
                                                          } }, {
                                                            monthly_income: {
                                                              gross: 220.0,
                                                              tax: -131.50,
                                                              national_insurance: -17.0,
                                                              prisoner_levy: 0.0,
                                                              student_debt_repayment: 0.0,
                                                              benefits_in_kind: 20.0,
                                                            },
                                                          })
        end
      end

      context "with employment income without payments" do
        let(:params) { { employment_income: employment_income_without_payments_params } }

        describe "employment_income" do
          let(:employment_income) { parsed_response.dig(:result_summary, :disposable_income, :employment_income) }

          it "has employment income with 0 deductions" do
            expect(employment_income)
              .to eq(
                {
                  gross_income: 0.0,
                  benefits_in_kind: 0.0,
                  tax: 0.0,
                  national_insurance: 0.0,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  fixed_employment_deduction: 0.0,
                  net_employment_income: 0.0,
                },
              )
          end
        end
      end

      context "without dependants, cash transactions or employment income" do
        let(:payment_date) { "2022-05-15" }
        let(:outgoings_params) do
          [
            {
              name: "child_care",
              payments: [
                {
                  payment_date:,
                  amount: 29.12,
                  client_id: client_ids.first,
                },
              ],
            },
            {
              name: "legal_aid",
              payments: [
                {
                  payment_date:,
                  amount: 19.87,
                  client_id: client_ids.first,
                },
              ],
            },
            {
              name: "maintenance_out",
              payments: %w[
                2022-10-15
                2022-11-15
                2022-12-15
              ].map { |v| { amount: 333.07, client_id: SecureRandom.uuid, payment_date: v } },
            },
            {
              name: "rent_or_mortgage",
              payments: [
                {
                  payment_date:,
                  amount: 351.49,
                  housing_cost_type: "rent",
                  client_id: "hc-r-1",
                },
              ],
            },
          ]
        end

        let(:other_income_params) do
          [
            {
              source: "maintenance_in",
              payments: [{ date: "2022-11-01" },
                         { date: "2022-10-01" },
                         { date: "2022-09-01" }].map.with_index do |p, index|
                          p.merge(
                            amount: 1046.44,
                            client_id: "oi-m-#{index}",
                          )
                        end,
            },
            {
              source: "friends_or_family",
              payments: [
                {
                  date: "2022-11-01",
                  amount: 250.00,
                },
                {
                  date: "2022-10-01",
                  amount: 266.02,
                },
                {
                  date: "2022-09-01",
                  amount: 250.00,
                },
              ].map.with_index { |p, index| p.merge(client_id: "ffi-m-#{index + 1}") },
            },
          ]
        end

        let(:client_ids) { %w[1 2 3] }

        let(:benefit_type_excluded) { create :state_benefit_type, exclude_from_gross_income: true }
        let(:benefit_type_included) { create :state_benefit_type, exclude_from_gross_income: false }
        let(:state_benefit_params) do
          [
            {
              name: benefit_type_excluded.label,
              payments: %w[2022-11-01 2022-10-01 2022-09-01].map.with_index do |date, index|
                {
                  date:, amount: 1033.44, client_id: "sb1-m#{index}"
                }
              end,
            },
            {
              name: benefit_type_included.label,
              payments: %w[2022-11-01 2022-10-01 2022-09-01].map.with_index do |date, index|
                {
                  date:, amount: 266.02, client_id: "sb2-m#{index}"
                }
              end,
            },
          ]
        end

        let(:params) do
          {
            other_incomes: other_income_params,
            properties: {
              main_home: {
                value: 500_000,
                outstanding_mortgage: 200,
                percentage_owned: 15,
                shared_with_housing_assoc: true,
                subject_matter_of_dispute: false,
              },
              additional_properties: properties_params,
            },
            vehicles: vehicle_params,
            irregular_incomes: irregular_income_params,
            state_benefits: state_benefit_params,
            regular_transactions: [{ category: "maintenance_in",
                                     operation: "credit",
                                     amount: 9.99,
                                     frequency: "monthly" }],
            outgoings: outgoings_params,
            partner: {
              partner: { date_of_birth: "1987-08-08", employed: true },
              cash_transactions: cash_transactions_params,
              irregular_incomes: irregular_income_payments,
              employments: employment_income_params,
              regular_transactions: [
                { category: "maintenance_in",
                  operation: "credit",
                  amount: 29.99,
                  frequency: "monthly" },
                { category: "child_care",
                  operation: "debit",
                  amount: 73.27,
                  frequency: "monthly" },
              ],
              state_benefits: state_benefit_params,
              additional_properties: properties_params,
              outgoings: outgoings_params,
              other_incomes: other_income_params,
              capitals: {
                bank_accounts: bank_account_params,
                non_liquid_capital: non_liquid_params,
              },
              dependants: dependant_params_with_monthly_income,
              vehicles: vehicle_params,
            },
          }
        end

        describe "redacted logs" do
          let(:partner_log) do
            log_record.request["partner"].deep_symbolize_keys.except(:irregular_incomes, :employments, :capitals, :vehicles,
                                                                     :regular_transactions, :additional_properties)
          end
          let(:redacted_log) do
            log_record.request.deep_symbolize_keys.except(:assessment, :applicant, :proceeding_types, :irregular_incomes,
                                                          :regular_transactions,
                                                          :properties, :vehicles, :dependants, :partner)
          end

          it "logs redacted partner dob" do
            expect(partner_log.fetch(:partner))
              .to eq(
                { date_of_birth: "1987-06-07", employed: true },
              )
          end

          it "logs redacted dependants dob" do
            expect(partner_log.fetch(:dependants))
              .to eq(
                [{ date_of_birth: "2014-06-07", in_full_time_education: true, relationship: "child_relative", monthly_income: 0, assets_value: 0.0 },
                 { date_of_birth: "2013-06-07", in_full_time_education: true, relationship: "child_relative", monthly_income: 0, assets_value: 0.0 },
                 { date_of_birth: "2004-06-07", in_full_time_education: true, relationship: "child_relative", monthly_income: 0, assets_value: 0.0 }],
              )
          end

          it "redacts partner state benefits client ids" do
            expect(partner_log.fetch(:state_benefits).map { |sb| sb.fetch(:payments) })
              .to eq(
                [
                  [{ date: "2022-11-01", amount: 1033.44, client_id: redacted_message },
                   { date: "2022-10-01", amount: 1033.44, client_id: redacted_message },
                   { date: "2022-09-01", amount: 1033.44, client_id: redacted_message }],
                  [{ date: "2022-11-01", amount: 266.02, client_id: redacted_message },
                   { date: "2022-10-01", amount: 266.02, client_id: redacted_message },
                   { date: "2022-09-01", amount: 266.02, client_id: redacted_message }],
                ],
              )
          end

          it "logs redacted" do
            expect(partner_log.except(:partner, :dependants, :state_benefits, :cash_transactions))
              .to eq(
                {
                  other_incomes: [{ source: "maintenance_in",
                                    payments: [{ date: "2022-11-01", amount: 1046.44, client_id: redacted_message },
                                               { date: "2022-10-01", amount: 1046.44, client_id: redacted_message },
                                               { date: "2022-09-01", amount: 1046.44, client_id: redacted_message }] },
                                  { source: "friends_or_family",
                                    payments: [{ date: "2022-11-01", amount: 250.0, client_id: redacted_message },
                                               { date: "2022-10-01", amount: 266.02, client_id: redacted_message },
                                               { date: "2022-09-01", amount: 250.0, client_id: redacted_message }] }],
                  outgoings: [{ name: "child_care", payments: [{ payment_date: "2022-05-15", amount: 29.12, client_id: redacted_message }] },
                              { name: "legal_aid", payments: [{ payment_date: "2022-05-15", amount: 19.87, client_id: redacted_message }] },
                              { name: "maintenance_out",
                                payments: [{ amount: 333.07, client_id: redacted_message, payment_date: "2022-10-15" },
                                           { amount: 333.07, client_id: redacted_message, payment_date: "2022-11-15" },
                                           { amount: 333.07, client_id: redacted_message, payment_date: "2022-12-15" }] },
                              { name: "rent_or_mortgage", payments: [{ payment_date: "2022-05-15", amount: 351.49, housing_cost_type: "rent", client_id: redacted_message }] }],
                },
              )
          end

          it "redacts state benefits client ids" do
            expect(redacted_log.fetch(:state_benefits).map { |sb| sb.fetch(:payments) })
              .to eq(
                [
                  [{ date: "2022-11-01", amount: 1033.44, client_id: redacted_message },
                   { date: "2022-10-01", amount: 1033.44, client_id: redacted_message },
                   { date: "2022-09-01", amount: 1033.44, client_id: redacted_message }],
                  [{ date: "2022-11-01", amount: 266.02, client_id: redacted_message },
                   { date: "2022-10-01", amount: 266.02, client_id: redacted_message },
                   { date: "2022-09-01", amount: 266.02, client_id: redacted_message }],
                ],
              )
          end

          it "redacts the client ids in the log" do
            expect(redacted_log.except(:state_benefits))
              .to eq(
                {
                  other_incomes: [
                    { source: "maintenance_in",
                      payments: [{ date: "2022-11-01", amount: 1046.44, client_id: redacted_message },
                                 { date: "2022-10-01", amount: 1046.44, client_id: redacted_message },
                                 { date: "2022-09-01", amount: 1046.44, client_id: redacted_message }] },
                    { source: "friends_or_family",
                      payments: [{ date: "2022-11-01", amount: 250.0, client_id: redacted_message },
                                 { date: "2022-10-01", amount: 266.02, client_id: redacted_message },
                                 { date: "2022-09-01", amount: 250.0, client_id: redacted_message }] },
                  ],
                  outgoings: [
                    { name: "child_care", payments: [{ payment_date: "2022-05-15", amount: 29.12, client_id: redacted_message }] },
                    { name: "legal_aid", payments: [{ payment_date: "2022-05-15", amount: 19.87, client_id: redacted_message }] },
                    { name: "maintenance_out",
                      payments: [{ amount: 333.07, client_id: redacted_message, payment_date: "2022-10-15" },
                                 { amount: 333.07, client_id: redacted_message, payment_date: "2022-11-15" },
                                 { amount: 333.07, client_id: redacted_message, payment_date: "2022-12-15" }] },
                    { name: "rent_or_mortgage",
                      payments: [
                        { payment_date: "2022-05-15", amount: 351.49, housing_cost_type: "rent", client_id: redacted_message },
                      ] },
                  ],
                },
              )
          end
        end

        it "contains JSON version and success" do
          expect(parsed_response.except(:timestamp, :result_summary, :assessment)).to eq({ version: "6", success: true })
        end

        describe "result summary" do
          let(:summary) { parsed_response.fetch(:result_summary) }

          it "has income and capital keys for parner and applicant" do
            expect(summary.keys).to match_array(%i[overall_result
                                                   gross_income
                                                   partner_gross_income
                                                   disposable_income
                                                   partner_disposable_income
                                                   capital
                                                   partner_capital])
          end

          describe "overall_result" do
            it "is contribution_required" do
              expect(summary.fetch(:overall_result).except(:proceeding_types))
                .to eq({
                  result: "contribution_required",
                  capital_contribution: 19_636.86,
                  income_contribution: 1564.65,
                })
            end
          end

          it "has disposable income" do
            expect(summary.fetch(:disposable_income).except(:proceeding_types,
                                                            :income_contribution,
                                                            :combined_total_outgoings_and_allowances,
                                                            :total_disposable_income, :combined_total_disposable_income,
                                                            :total_outgoings_and_allowances))
              .to eq(
                {
                  dependant_allowance_under_16: 0.0,
                  dependant_allowance_over_16: 0.0,
                  dependant_allowance: 0.0,
                  gross_housing_costs: 117.16,
                  housing_costs: 117.16,
                  housing_benefit: 0.0,
                  net_housing_costs: 117.16,
                  allowed_housing_costs: 117.16,
                  maintenance_allowance: 333.07,
                  employment_income: {
                    gross_income: 0.0,
                    benefits_in_kind: 0.0,
                    tax: 0.0,
                    national_insurance: 0.0,
                    prisoner_levy: 0.0,
                    student_debt_repayment: 0.0,
                    fixed_employment_deduction: 0.0,
                    net_employment_income: 0.0,
                  },
                  partner_allowance: 191.41,
                  lone_parent_allowance: 0,
                },
              )
          end

          it "has partner disposable income" do
            expect(summary.fetch(:partner_disposable_income)).to eq(
              {
                dependant_allowance_under_16: 615.28,
                dependant_allowance_over_16: 307.64,
                dependant_allowance: 922.92,
                gross_housing_costs: 204.7,
                housing_costs: 204.7,
                housing_benefit: 0.0,
                net_housing_costs: 204.7,
                allowed_housing_costs: 204.7,
                maintenance_allowance: 589.07,
                total_outgoings_and_allowances: 2275.59,
                total_disposable_income: 1708.335,
                employment_income: {
                  gross_income: 846.0,
                  benefits_in_kind: 16.6,
                  tax: -104.1,
                  national_insurance: -18.66,
                  prisoner_levy: 0.0,
                  student_debt_repayment: 0.0,
                  fixed_employment_deduction: -45.0,
                  net_employment_income: 694.84,
                },
              },
            )
          end

          it "has capital" do
            expect(summary.fetch(:capital).except(:proceeding_types, :capital_contribution,
                                                  :total_mortgage_allowance))
              .to eq({
                total_liquid: 0.0,
                total_non_liquid: 0.0,
                total_vehicle: 2638.69,
                total_property: 8620.3,
                total_capital: 11_258.99,
                pensioner_capital_disregard: 0.0,
                disputed_non_property_disregard: 0.0,
                subject_matter_of_dispute_disregard: 0.0,
                assessed_capital: 11_258.99,
                total_capital_with_smod: 11_258.99,
                pensioner_disregard_applied: 0.0,
                combined_disputed_capital: 0.0,
                combined_assessed_capital: 22_636.86,
                combined_non_disputed_capital: 22_636.86,
              })
          end

          it "has partner capital" do
            expect(summary.fetch(:partner_capital).except(:assessed_capital, :total_mortgage_allowance))
              .to eq(
                {
                  total_liquid: 95.57,
                  total_non_liquid: 23.31,
                  total_vehicle: 2638.69,
                  total_property: 8620.3,
                  total_capital: 11_377.87,
                  total_capital_with_smod: 11_377.87,
                  pensioner_disregard_applied: 0.0,
                  disputed_non_property_disregard: 0.0,
                  subject_matter_of_dispute_disregard: 0.0,
                },
              )
          end
        end

        describe "assessment" do
          it "has keys for applicant and nested income and partner" do
            expect(assessment.keys).to match_array(%i[client_reference_id
                                                      submission_date
                                                      level_of_help
                                                      applicant
                                                      gross_income
                                                      partner_gross_income
                                                      disposable_income
                                                      partner_disposable_income
                                                      capital
                                                      partner_capital
                                                      remarks])
          end

          describe "remarks" do
            let(:remarks) { assessment.fetch(:remarks) }

            it "has client_other_income_payment remark from friends and family" do
              expect(remarks.dig(:client_other_income_payment, :amount_variation))
                .to contain_exactly("ffi-m-3", "ffi-m-2", "ffi-m-1")
            end

            it "has partner_other_income_payment remark from friends and family" do
              expect(remarks.dig(:partner_other_income_payment, :amount_variation))
                .to contain_exactly("ffi-m-3", "ffi-m-2", "ffi-m-1")
            end

            it "has client_outgoings_housing_cost" do
              expect(remarks.fetch(:client_outgoings_housing_cost)).to eq(
                { unknown_frequency: ["hc-r-1"] },
              )
            end

            it "has partner_outgoings_housing_cost" do
              expect(remarks.fetch(:partner_outgoings_housing_cost)).to eq(
                { unknown_frequency: ["hc-r-1"] },
              )
            end
          end

          it "has applicant" do
            expect(assessment.fetch(:applicant)).to eq(
              {
                date_of_birth: dob,
                involvement_type: "applicant",
                employed: false,
                has_partner_opponent: false,
                receives_qualifying_benefit: false,
              },
            )
          end

          describe "gross income" do
            let(:gross_income) { assessment.fetch(:gross_income) }

            it "has correct keys" do
              expect(gross_income.keys).to eq(%i[employment_income irregular_income state_benefits other_income])
            end

            it "has irregular income" do
              expect(gross_income.fetch(:irregular_income)).to eq(
                { monthly_equivalents: { student_loan: 38.065, unspecified_source: 10.92 } },
              )
            end

            describe "state benefits" do
              let(:monthly_equivalents) { gross_income.dig(:state_benefits, :monthly_equivalents) }

              it "has bank transactions" do
                expect(monthly_equivalents.fetch(:bank_transactions)).to contain_exactly({ name: benefit_type_excluded.label, monthly_value: 1033.44, excluded_from_income_assessment: true }, { name: benefit_type_included.label, monthly_value: 266.02, excluded_from_income_assessment: false })
              end
            end

            describe "other income" do
              let(:other_income) { gross_income.fetch(:other_income) }

              describe "monthly_equivalents" do
                let(:monthly_equivalents) { other_income.fetch(:monthly_equivalents) }

                it "has all_sources" do
                  expect(monthly_equivalents.fetch(:all_sources)).to eq(
                    {
                      friends_or_family: 255.34,
                      maintenance_in: 1056.43,
                      property_or_lodger: 0.0,
                      pension: 0.0,
                    },
                  )
                end

                it "has bank_transactions" do
                  expect(monthly_equivalents.fetch(:bank_transactions)).to eq(
                    {
                      friends_or_family: 255.34,
                      maintenance_in: 1046.44,
                      property_or_lodger: 0.0,
                      pension: 0.0,
                    },
                  )
                end

                it "has cash_transactions" do
                  expect(monthly_equivalents.fetch(:cash_transactions)).to eq(
                    {
                      friends_or_family: 0.0,
                      maintenance_in: 0.0,
                      property_or_lodger: 0.0,
                      pension: 0.0,
                    },
                  )
                end
              end
            end
          end

          describe "partner_gross_income" do
            let(:partner_gross_income) { assessment.fetch(:partner_gross_income) }

            it "has the correct keys" do
              expect(partner_gross_income.keys).to match_array(%i[employment_income irregular_income state_benefits other_income])
            end

            describe "employment_income" do
              it "has the correct payments" do
                expect(partner_gross_income[:employment_income].map { |x| x.fetch(:payments) }).to eq(
                  [
                    [
                      { date: "2022-05-30", gross: 846.0, benefits_in_kind: 16.6, tax: -104.1, national_insurance: -18.66, prisoner_levy: 0.0, student_debt_repayment: 0.0, net_employment_income: 739.84 },
                      { date: "2022-04-30", gross: 846.0, benefits_in_kind: 16.6, tax: -104.1, national_insurance: -18.66, prisoner_levy: 0.0, student_debt_repayment: 0.0, net_employment_income: 739.84 },
                      { date: "2022-03-30", gross: 846.0, benefits_in_kind: 16.6, tax: -104.1, national_insurance: -18.66, prisoner_levy: 0.0, student_debt_repayment: 0.0, net_employment_income: 739.84 },
                    ],
                  ],
                )
              end
            end

            describe "irregular_income" do
              it "has monthly equivalents" do
                expect(partner_gross_income.dig(:irregular_income, :monthly_equivalents)).to eq(
                  {
                    student_loan: 38.065,
                    unspecified_source: 10.92,
                  },
                )
              end
            end

            describe "state_benefits" do
              let(:state_benefits) { partner_gross_income.dig(:state_benefits, :monthly_equivalents) }

              it "has cash_transactions" do
                expect(state_benefits.excluding(:bank_transactions)).to eq(
                  {
                    all_sources: 331.14,
                    cash_transactions: 65.12,
                  },
                )
              end

              it "has bank_transactions" do
                expect(state_benefits.fetch(:bank_transactions).map { |g| g.except(:name) }).to contain_exactly({ monthly_value: 1033.44, excluded_from_income_assessment: true }, { monthly_value: 266.02, excluded_from_income_assessment: false })
              end
            end

            describe "other_income" do
              it "has monthly equivalents" do
                expect(partner_gross_income.dig(:other_income, :monthly_equivalents)).to eq(
                  {
                    all_sources: {
                      friends_or_family: 505.34,
                      maintenance_in: 2109.87,
                      property_or_lodger: 91.87,
                      pension: 34.12,
                    },
                    bank_transactions: { friends_or_family: 255.34,
                                         maintenance_in: 1046.44,
                                         property_or_lodger: 0.0,
                                         pension: 0.0 },
                    cash_transactions: {
                      friends_or_family: 250.0, maintenance_in: 1033.44, property_or_lodger: 91.87, pension: 34.12
                    },
                  },
                )
              end
            end
          end

          it "has disposable income" do
            expect(assessment.fetch(:disposable_income)).to eq(
              { monthly_equivalents: { all_sources: { child_care: 9.71, rent_or_mortgage: 117.16, maintenance_out: 333.07, legal_aid: 6.62, pension_contribution: 0.0, council_tax: 0.0, priority_debt_repayment: 0.0 },
                                       bank_transactions: { child_care: 9.71, rent_or_mortgage: 117.16, maintenance_out: 333.07, legal_aid: 6.62, pension_contribution: 0.0, council_tax: 0.0, priority_debt_repayment: 0.0 },
                                       cash_transactions: { child_care: 0.0, rent_or_mortgage: 0.0, maintenance_out: 0.0, legal_aid: 0.0, pension_contribution: 0.0, council_tax: 0.0, priority_debt_repayment: 0.0 } },
                childcare_allowance: 9.71,
                deductions: { dependants_allowance: 0.0, disregarded_state_benefits: 1033.44 } },
            )
          end

          it "has partner disposable income" do
            expect(assessment.fetch(:partner_disposable_income)).to eq(
              {
                monthly_equivalents: {
                  all_sources: {
                    child_care: 339.98,
                    rent_or_mortgage: 204.7,
                    maintenance_out: 589.07,
                    legal_aid: 51.16,
                    pension_contribution: 0.0,
                    council_tax: 0.0,
                    priority_debt_repayment: 0.0,
                  },
                  bank_transactions: {
                    child_care: 9.71,
                    rent_or_mortgage: 117.16,
                    maintenance_out: 333.07,
                    legal_aid: 6.62,
                    pension_contribution: 0.0,
                    council_tax: 0.0,
                    priority_debt_repayment: 0.0,
                  },
                  cash_transactions: {
                    child_care: 257.0,
                    rent_or_mortgage: 87.54,
                    maintenance_out: 256.0,
                    legal_aid: 44.54,
                    pension_contribution: 0.0,
                    council_tax: 0.0,
                    priority_debt_repayment: 0.0,
                  },
                },
                childcare_allowance: 339.98,
                deductions: { dependants_allowance: 922.92, disregarded_state_benefits: 1033.44 },
              },
            )
          end

          describe "capital items" do
            let(:capital_items) { assessment.fetch(:capital).fetch(:capital_items) }

            it "has vehicles" do
              expect(capital_items.fetch(:vehicles))
                .to eq(
                  [
                    {
                      value: 2638.69,
                      loan_amount_outstanding: 3907.77,
                      date_of_purchase: "2022-03-05",
                      in_regular_use: false,
                      included_in_assessment: true,
                      disregards_and_deductions: -3907.77,
                      assessed_value: 2638.69,
                    },
                    {
                      value: 4238.39,
                      loan_amount_outstanding: 6139.36,
                      date_of_purchase: "2021-09-23",
                      in_regular_use: true,
                      included_in_assessment: false,
                      disregards_and_deductions: -1900.9699999999993,
                      assessed_value: 0.0,
                    },
                  ],
                )
            end

            describe "has properties" do
              let(:properties) { capital_items.fetch(:properties) }

              context "without main home" do
                let(:params) { { properties: {} } }

                it "has a main home with 0 values" do
                  expect(properties.fetch(:main_home))
                    .to eq({
                      value: 0.0,
                      outstanding_mortgage: 0.0,
                      percentage_owned: 0.0,
                      main_home: true,
                      shared_with_housing_assoc: false,
                      transaction_allowance: 0.0,
                      allowable_outstanding_mortgage: 0.0,
                      net_value: 0.0,
                      net_equity: 0.0,
                      smod_allowance: 0,
                      main_home_equity_disregard: 0.0,
                      assessed_equity: 0.0,
                      subject_matter_of_dispute: false,
                    })
                end
              end

              context "with main home" do
                it "has a main home" do
                  expect(properties.fetch(:main_home))
                    .to eq({
                      value: 500_000.0,
                      outstanding_mortgage: 200.0,
                      percentage_owned: 15.0,
                      main_home: true,
                      shared_with_housing_assoc: true,
                      transaction_allowance: 15_000.0,
                      allowable_outstanding_mortgage: 200.0,
                      net_value: 484_800.0,
                      net_equity: 59_800.0,
                      main_home_equity_disregard: 59_800.0,
                      assessed_equity: 0.0,
                      smod_allowance: 0.0,
                      subject_matter_of_dispute: false,
                    })
                end

                it "has additional properties" do
                  expect(properties.fetch(:additional_properties))
                    .to contain_exactly({
                      value: 1000.0,
                      outstanding_mortgage: 0.0,
                      percentage_owned: 99.0,
                      main_home: false,
                      shared_with_housing_assoc: false,
                      transaction_allowance: 30.0,
                      allowable_outstanding_mortgage: 0.0,
                      net_value: 970.0,
                      net_equity: 960.3,
                      main_home_equity_disregard: 0.0,
                      assessed_equity: 960.3,
                      smod_allowance: 0.0,
                      subject_matter_of_dispute: false,
                    }, {
                      value: 10_000.0,
                      outstanding_mortgage: 40.0,
                      percentage_owned: 80.0,
                      main_home: false,
                      shared_with_housing_assoc: true,
                      transaction_allowance: 300.0,
                      allowable_outstanding_mortgage: 40.0,
                      net_value: 9660.0,
                      net_equity: 7660.0,
                      main_home_equity_disregard: 0.0,
                      assessed_equity: 7660.0,
                      smod_allowance: 0.0,
                      subject_matter_of_dispute: false,
                    })
                end
              end
            end
          end

          describe "partner_capital" do
            let(:partner_capital) { assessment.dig(:partner_capital, :capital_items) }

            it "has liquid" do
              expect(partner_capital.fetch(:liquid).map { |x| x.except(:description) })
                .to contain_exactly({ value: 28.34 }, { value: 67.23 })
            end

            it "has non_liquid" do
              expect(partner_capital.fetch(:non_liquid).map { |x| x.except(:description) })
                .to contain_exactly({ value: 17.12 }, { value: 6.19 })
            end

            it "has vehicles" do
              expect(partner_capital.fetch(:vehicles).map { |v| v.except(:date_of_purchase, :disregards_and_deductions) }).to eq(
                [
                  {
                    value: 2638.69,
                    loan_amount_outstanding: 3907.77,
                    in_regular_use: false,
                    included_in_assessment: true,
                    assessed_value: 2638.69,
                  },
                  {
                    value: 4238.39,
                    loan_amount_outstanding: 6139.36,
                    in_regular_use: true,
                    included_in_assessment: false,
                    assessed_value: 0.0,
                  },
                ],
              )
            end

            it "has properties" do
              expect(partner_capital.dig(:properties, :additional_properties))
                .to contain_exactly({
                  value: 1000.0,
                  outstanding_mortgage: 0.0,
                  percentage_owned: 99.0,
                  main_home: false,
                  shared_with_housing_assoc: false,
                  transaction_allowance: 30.0,
                  allowable_outstanding_mortgage: 0.0,
                  net_value: 970.0,
                  net_equity: 960.3,
                  main_home_equity_disregard: 0.0,
                  assessed_equity: 960.3,
                  smod_allowance: 0.0,
                  subject_matter_of_dispute: false,
                }, {
                  value: 10_000.0,
                  outstanding_mortgage: 40.0,
                  percentage_owned: 80.0,
                  main_home: false,
                  shared_with_housing_assoc: true,
                  transaction_allowance: 300.0,
                  allowable_outstanding_mortgage: 40.0,
                  net_value: 9660.0,
                  net_equity: 7660.0,
                  main_home_equity_disregard: 0.0,
                  assessed_equity: 7660.0,
                  smod_allowance: 0.0,
                  subject_matter_of_dispute: false,
                })
            end
          end
        end
      end

      context "redact response timestamp" do
        # control the run date for timestamps
        around do |example|
          travel_to Date.new(2022, 7, 20)
          example.run
          travel_back
        end

        context "with successful submission" do
          let(:params) { {} }

          it "returns http success" do
            expect(response).to have_http_status(:success)
          end

          it "returns timestamp attribute in response" do
            expect(parsed_response).to be_key(:timestamp)
          end

          it "returns timestamp in response" do
            expect(parsed_response[:timestamp]).to eq("2022-07-20T00:00:00.000Z")
          end

          it "redacts time in timestamp" do
            expect(log_record.response["timestamp"]).to eq("2022-07-20")
          end

          context "client_reference_id" do
            before do
              RequestLog.update_all(created_at: 3.weeks.ago)
              RedactService.redact_old_client_refs
            end

            context "when assessment.client_reference_id is present" do
              let(:params) { { assessment: { client_reference_id: client_ref } } }

              it "redacts the client reference" do
                expect(log_record.request["assessment"]["client_reference_id"]).to eq(redacted_message)
              end
            end

            context "when assessment.client_reference_id not present" do
              let(:params) { { assessment: {} } }

              it "doesn't redact the client reference" do
                expect(log_record.request["assessment"]["client_reference_id"]).to be_nil
              end
            end
          end
        end

        context "with unsuccessful submission" do
          let(:params) { { assessment: { client_reference_id: client_ref } } }

          it "returns http error" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "redacts the client reference" do
            RequestLog.update_all(created_at: 3.weeks.ago)
            RedactService.redact_old_client_refs

            expect(log_record.request["assessment"]["client_reference_id"]).to eq(redacted_message)
          end

          it "doesnt redact new client references" do
            RedactService.redact_old_client_refs

            expect(log_record.request["assessment"]["client_reference_id"]).to eq(client_ref)
          end

          it "missing timestamp attribute in response" do
            expect(parsed_response).not_to be_key(:timestamp)
          end
        end
      end

      context "redact assessment.remarks in response" do
        context "with successful submission" do
          let(:params) do
            {
              employment_income: [
                {
                  name: "Job 1",
                  client_id: "xxx",
                  payments: [
                    {
                      client_id: "client_id_1",
                      date: "2023-01-31",
                      gross: 2024.0,
                      benefits_in_kind: 0.0,
                      tax: -194.2,
                      national_insurance: -117.12,
                    },
                    {
                      client_id: "client_id_2",
                      date: "2022-12-31",
                      gross: 1936.0,
                      benefits_in_kind: 0.0,
                      tax: -176.6,
                      national_insurance: -106.56,
                    },
                  ],
                },
              ],
              explicit_remarks: [
                {
                  category: "policy_disregards",
                  details: [
                    "Grenfell tower fund",
                    "Some other fund",
                  ],
                },
              ],
            }
          end

          it "returns assessment.remarks client_ids in response" do
            expect(parsed_response[:assessment][:remarks]).to eq(client_employment_payment: { unknown_frequency: %w[client_id_1 client_id_2] }, policy_disregards: ["Grenfell tower fund", "Some other fund"])
          end

          it "redacts assessment.remarks client_ids in RequestLog" do
            expect(log_record.response["assessment"]["remarks"]).to eq("client_employment_payment" => { "unknown_frequency" => ["** REDACTED **", "** REDACTED **"] }, "policy_disregards" => ["Grenfell tower fund", "Some other fund"])
          end
        end
      end
    end
  end
end
