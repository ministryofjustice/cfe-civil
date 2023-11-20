require "rails_helper"

module Calculators
  RSpec.describe HousingCostsCalculator, :calls_bank_holiday do
    let(:housing_benefit_type) { create :state_benefit_type, label: "housing_benefit" }
    let(:assessment) do
      create :assessment, :with_gross_income_summary,
             :with_disposable_income_summary,
             submission_date:
    end

    subject(:calculator) do
      described_class.call(housing_cost_outgoings:,
                           housing_costs_cap_applies:,
                           monthly_housing_benefit: housing_benefit_amount,
                           submission_date: assessment.submission_date,
                           regular_transactions: [],
                           gross_income_summary: assessment.applicant_gross_income_summary)
    end

    context "when using outgoings and state_benefits" do
      let(:housing_cost_outgoings) do
        [submission_date - 2.months, submission_date - 1.month, submission_date].map do |date|
          build :housing_cost_outgoing,
                payment_date: date,
                amount: housing_cost_amount,
                housing_cost_type:
        end
      end

      context "before MTR, with housing benefit in disposable income" do
        let(:submission_date) { Date.new(2022, 6, 6) }

        context "when applicant has no dependants" do
          let(:housing_cost_amount) { 1200.00 }
          let(:housing_costs_cap_applies) { true }

          context "and does not receive housing benefit" do
            let(:housing_benefit_amount) { 0.00 }

            context "with board and lodging" do
              let(:housing_cost_type) { "board_and_lodging" }
              let(:housing_cost_amount) { 1500.00 }

              it "caps the return" do
                expect(calculator)
                  .to have_attributes(housing_costs: 750.00,
                                      allowed_housing_costs: 545.00) # Cap applied
              end

              context "when 50% of monthly bank and cash outgoings are below the cap" do
                let(:housing_cost_amount) { 888.0 }

                it "returns the gross cost as net" do
                  expect(calculator)
                    .to have_attributes(
                      housing_costs: 444.0,
                      allowed_housing_costs: 444.0,
                    )
                end
              end
            end

            context "with mortgage" do
              let(:housing_cost_type) { "mortgage" }

              it "caps the return" do
                expect(calculator)
                  .to have_attributes(
                    housing_costs: 1200.0,
                    allowed_housing_costs: 545.0, # Cap applied
                  )
              end

              context "when net cost is below housing cap" do
                let(:housing_cost_amount) { 420.00 }

                it "returns the net cost" do
                  expect(calculator)
                    .to have_attributes(
                      housing_costs: 420.0,
                      allowed_housing_costs: 420.0,
                    )
                end
              end
            end
          end

          context "and receives housing benefit as a state_benefit" do
            let(:housing_benefit_amount) { 500.00 }

            context "with board and lodging" do
              let(:housing_cost_type) { "board_and_lodging" }
              let(:housing_cost_amount) { 1500.00 }
              let(:housing_benefit_amount) { 100.00 }

              it "caps the return" do
                expect(calculator)
                  .to have_attributes(
                    housing_costs: 750.0,
                    allowed_housing_costs: 545.0, # Cap applied
                  )
              end
            end

            context "with rent" do
              let(:housing_cost_type) { "rent" }

              it "caps the return" do
                expect(calculator)
                  .to have_attributes(
                    housing_costs: 1200.0,
                    allowed_housing_costs: 545.0, # Cap applied
                  )
              end

              context "when net cost is below housing cap" do
                let(:housing_cost_amount) { 1000.00 }
                let(:housing_benefit_amount) { 600.00 }

                it "returns gross less housing benefits" do
                  expect(calculator)
                    .to have_attributes(
                      housing_costs: 1000.0,
                      allowed_housing_costs: 400.0,
                    )
                end
              end
            end
          end
        end

        context "when applicant has dependants" do
          let(:housing_costs_cap_applies) { false }
          let(:housing_cost_amount) { 1200.00 }

          context "with no housing benefit" do
            let(:housing_benefit_amount) { 0 }

            context "board and lodging" do
              let(:housing_cost_type) { "board_and_lodging" }

              it "records half the monthly housing cost" do
                expect(calculator)
                  .to have_attributes(
                    housing_costs: 600.00,
                    allowed_housing_costs: 600.00,
                  )
              end
            end

            context "mortgage" do
              let(:housing_cost_type) { "mortgage" }

              it "records the full monthly housing costs" do
                expect(calculator)
                  .to have_attributes(
                    housing_costs: 1200.00,
                    allowed_housing_costs: 1200.00,
                  )
              end
            end
          end

          context "with weekly housing benefit" do
            let(:housing_benefit_amount) { 500.00 }
            let(:housing_cost_type) { "rent" }

            let(:housing_benefit_payments) do
              [submission_date - 4.weeks, submission_date - 3.weeks, submission_date - 2.weeks, submission_date - 1.week, submission_date].map do |pay_date|
                build :state_benefit_payment, amount: housing_benefit_amount, payment_date: pay_date
              end
            end

            it "records the full monthly housing costs" do
              expect(calculator).to have_attributes(housing_costs: 1200.00)
            end
          end

          context "with housing benefit as a state_benefit" do
            let(:housing_benefit_amount) { 500.00 }

            context "board and lodging" do
              let(:housing_cost_type) { "board_and_lodging" }
              let(:housing_cost_amount) { 1200.00 }
              let(:housing_benefit_amount) { 100.00 }

              it "records half the monthly outgoing less the housing benefit" do
                expect(calculator)
                  .to have_attributes(housing_costs: 600.00,
                                      allowed_housing_costs: housing_cost_amount.to_d / 2 - housing_benefit_amount.to_d)
              end
            end

            context "rent" do
              let(:housing_cost_type) { "rent" }

              it "records the full monthly housing costs" do
                expect(calculator)
                  .to have_attributes(housing_costs: 1200.00,
                                      allowed_housing_costs: 700.00)
              end
            end
          end
        end
      end

      context "after MTR, housing benefit in gross income" do
        let(:submission_date) { Date.new(2525, 6, 6) }
        let(:housing_benefit_payments) do
          [build(:state_benefit_payment, payment_amount: housing_benefit_amount)]
        end

        let(:housing_benefit_amount) { 500.00 }
        let(:housing_cost_amount) { 1200.00 }
        let(:housing_costs_cap_applies) { false } # MTR has an infinite housing cost cap so not much point setting this to true

        # need to time travel to submission date to prevent payment dates being in the future
        around do |example|
          travel_to submission_date
          example.run
          travel_back
        end

        context "mortgage" do
          let(:housing_cost_type) { "mortgage" }

          it "returns net the same as gross" do
            expect(calculator)
              .to have_attributes(housing_costs: 1200.00,
                                  allowed_housing_costs: 1200.00)
          end
        end

        context "board_and_lodging" do
          let(:housing_cost_type) { "board_and_lodging" }

          it "returns half the vakue, net the same as gross" do
            expect(calculator)
              .to have_attributes(housing_costs: 600.00,
                                  allowed_housing_costs: 600.00)
          end
        end
      end
    end
  end
end
