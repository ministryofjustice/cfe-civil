require "rails_helper"

module Calculators
  RSpec.describe HousingCostsCalculator, :calls_bank_holiday do
    let(:housing_benefit_type) { create :state_benefit_type, label: "housing_benefit" }

    subject(:calculator) do
      described_class.call(housing_cost_outgoings: assessment.applicant_disposable_income_summary.housing_cost_outgoings,
                           housing_costs_cap_applies: children.zero?,
                           submission_date: assessment.submission_date,
                           gross_income_summary: assessment.applicant_gross_income_summary)
    end

    context "when using outgoings and state_benefits" do
      let(:submission_date) { Date.new(2022, 6, 6) }
      let(:assessment) do
        create :assessment, :with_gross_income_summary,
               :with_disposable_income_summary,
               submission_date:
      end
      let(:rent_or_mortgage_transactions) { rent_or_mortgage_category.cash_transactions.order(:date) }
      let(:rent_or_mortgage_category) { create(:rent_or_mortgage_transaction_category, gross_income_summary: assessment.applicant_gross_income_summary) }

      before do
        [submission_date - 2.months, submission_date - 1.month, submission_date].each do |date|
          create :housing_cost_outgoing,
                 disposable_income_summary: assessment.applicant_disposable_income_summary,
                 payment_date: date,
                 amount: housing_cost_amount,
                 housing_cost_type:
        end
      end

      context "when applicant has no dependants" do
        let(:housing_cost_amount) { 1200.00 }
        let(:children) { 0 }

        context "and does not receive housing benefit" do
          context "with board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }
            let(:housing_cost_amount) { 1500.00 }

            it "caps the return" do
              expect(calculator)
                .to have_attributes(gross_housing_costs: 750.00,
                                    monthly_housing_benefit: 0.0,
                                    net_housing_costs: 545.00) # Cap applied
            end

            context "when 50% of monthly bank outgoings are below the cap but overall above it when including cash payments" do
              before do
                create(:cash_transaction, cash_transaction_category: rent_or_mortgage_category, amount: 20)
              end

              let(:housing_cost_amount) { 1088.00 }

              it "caps the net costs" do
                expect(calculator)
                  .to have_attributes(gross_housing_costs: 564.00,
                                      monthly_housing_benefit: 0.0,
                                      net_housing_costs: 545.00) # Cap applied
              end
            end

            context "when 50% of monthly bank and cash outgoings are below the cap" do
              let(:housing_cost_amount) { 888.0 }

              it "returns the gross cost as net" do
                expect(calculator)
                  .to have_attributes(
                    gross_housing_costs: 444.0,
                    monthly_housing_benefit: 0.0,
                    net_housing_costs: 444.0,
                  )
              end
            end
          end

          context "with rent" do
            let(:housing_cost_type) { "rent" }

            it "caps the return" do
              expect(calculator)
                .to have_attributes(
                  gross_housing_costs: 1200.0,
                  monthly_housing_benefit: 0.0,
                  net_housing_costs: 545.0, # Cap applied
                )
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 420.00 }

              it "returns the net cost" do
                expect(calculator)
                  .to have_attributes(
                    gross_housing_costs: 420.0,
                    monthly_housing_benefit: 0.0,
                    net_housing_costs: 420.0,
                  )
              end
            end
          end

          context "with mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "caps the return" do
              expect(calculator)
                .to have_attributes(
                  gross_housing_costs: 1200.0,
                  monthly_housing_benefit: 0.0,
                  net_housing_costs: 545.0, # Cap applied
                )
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 420.00 }

              it "returns the net cost" do
                expect(calculator)
                  .to have_attributes(
                    gross_housing_costs: 420.0,
                    monthly_housing_benefit: 0.0,
                    net_housing_costs: 420.0,
                  )
              end
            end
          end
        end

        context "and receives housing benefit as a state_benefit" do
          let(:housing_benefit_amount) { 500.00 }

          before do
            create :state_benefit, :with_monthly_payments,
                   payment_amount: housing_benefit_amount,
                   gross_income_summary: assessment.applicant_gross_income_summary, state_benefit_type: housing_benefit_type
          end

          context "with board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }
            let(:housing_cost_amount) { 1500.00 }
            let(:housing_benefit_amount) { 100.00 }

            it "caps the return" do
              expect(calculator)
                .to have_attributes(
                  gross_housing_costs: 750.0,
                  monthly_housing_benefit: 100.0,
                  net_housing_costs: 545.0, # Cap applied
                )
            end
          end

          context "with rent" do
            let(:housing_cost_type) { "rent" }

            it "caps the return" do
              expect(calculator)
                .to have_attributes(
                  gross_housing_costs: 1200.0,
                  monthly_housing_benefit: 500.0,
                  net_housing_costs: 545.0, # Cap applied
                )
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 1000.00 }
              let(:housing_benefit_amount) { 600.00 }

              it "returns gross less housing benefits" do
                expect(calculator)
                  .to have_attributes(
                    gross_housing_costs: 1000.0,
                    monthly_housing_benefit: 600.0,
                    net_housing_costs: 400.0,
                  )
              end
            end
          end

          context "with mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "caps the return" do
              expect(calculator)
                .to have_attributes(
                  gross_housing_costs: 1200.0,
                  monthly_housing_benefit: 500.0,
                  net_housing_costs: 545.0, # Cap applied
                )
            end

            context "when net amount will be below the cap" do
              let(:housing_cost_amount) { 600.00 }
              let(:housing_benefit_amount) { 200.00 }

              it "returns net as gross_cost minus housing_benefit" do
                expect(calculator)
                  .to have_attributes(
                    gross_housing_costs: 600.0,
                    monthly_housing_benefit: 200.0,
                    net_housing_costs: 400.0,
                  )
              end
            end
          end
        end
      end

      context "when applicant has dependants" do
        let(:children) { 1 }
        let(:housing_cost_amount) { 1200.00 }

        context "with no housing benefit" do
          context "board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }

            it "records half the monthly housing cost" do
              expect(calculator)
                .to have_attributes(
                  gross_housing_costs: 600.00,
                  monthly_housing_benefit: 0.0,
                  net_housing_costs: 600.00,
                )
            end
          end

          context "rent" do
            let(:housing_cost_type) { "rent" }

            it "records the full monthly housing costs" do
              expect(calculator)
                .to have_attributes(
                  gross_housing_costs: 1200.00,
                  monthly_housing_benefit: 0.0,
                  net_housing_costs: 1200.00,
                )
            end
          end

          context "mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "records the full monthly housing costs" do
              expect(calculator)
                .to have_attributes(
                  gross_housing_costs: 1200.00,
                  monthly_housing_benefit: 0.0,
                  net_housing_costs: 1200.00,
                )
            end
          end
        end

        context "with weekly housing benefit" do
          let(:housing_benefit_amount) { 500.00 }
          let(:housing_cost_type) { "rent" }
          let(:state_benefit) { create :state_benefit, gross_income_summary: assessment.applicant_gross_income_summary, state_benefit_type: housing_benefit_type }

          before do
            [submission_date - 4.weeks, submission_date - 3.weeks, submission_date - 2.weeks, submission_date - 1.week, submission_date].each do |pay_date|
              create :state_benefit_payment, state_benefit:, amount: housing_benefit_amount, payment_date: pay_date
            end
          end

          it "records the full monthly housing costs" do
            expect(calculator).to have_attributes(gross_housing_costs: 1200.00,
                                                  monthly_housing_benefit: 833.33)
          end
        end

        context "with housing benefit as a state_benefit" do
          let(:housing_benefit_amount) { 500.00 }

          before do
            create :state_benefit, :with_monthly_payments,
                   payment_amount: housing_benefit_amount,
                   gross_income_summary: assessment.applicant_gross_income_summary, state_benefit_type: housing_benefit_type
          end

          context "board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }
            let(:housing_cost_amount) { 1200.00 }
            let(:housing_benefit_amount) { 100.00 }

            it "records half the monthly outgoing less the housing benefit" do
              expect(calculator)
                .to have_attributes(gross_housing_costs: 600.00,
                                    monthly_housing_benefit: 100.000,
                                    net_housing_costs: (housing_cost_amount.to_d - housing_benefit_amount.to_d) / 2)
            end
          end

          context "rent" do
            let(:housing_cost_type) { "rent" }

            it "records the full monthly housing costs" do
              expect(calculator)
                .to have_attributes(gross_housing_costs: 1200.00,
                                    monthly_housing_benefit: 500.00,
                                    net_housing_costs: 700.00)
            end
          end

          context "mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "records the full housing costs less the housing benefit" do
              expect(calculator)
                .to have_attributes(gross_housing_costs: 1200.00,
                                    monthly_housing_benefit: 500.0,
                                    net_housing_costs: 700.00)
            end
          end
        end
      end
    end

    context "when using regular_transactions" do
      let(:instance) do
        described_class.call(housing_cost_outgoings: assessment.applicant_disposable_income_summary.housing_cost_outgoings,
                             gross_income_summary: assessment.applicant_gross_income_summary,
                             housing_costs_cap_applies: dependants.none?,
                             submission_date: assessment.submission_date)
      end
      let(:assessment) { create :assessment, :with_gross_income_summary, :with_disposable_income_summary }
      let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }

      describe "#gross_housing_costs" do
        subject(:gross_housing_costs) { instance.gross_housing_costs }

        context "with no housing costs" do
          let(:dependants) { [] }

          it { is_expected.to eq 0 }
        end

        context "with all forms of housing costs" do
          let(:dependants) { [] }

          before do
            # add monthly equivalent bank transactions of 111.11
            create(:housing_cost_outgoing, disposable_income_summary: assessment.applicant_disposable_income_summary, payment_date: dates[0], amount: 333.33)

            # add average cash transactions of 111.11
            rent_or_mortgage = create(:rent_or_mortgage_transaction_category, gross_income_summary: assessment.applicant_gross_income_summary)
            create(:cash_transaction, cash_transaction_category: rent_or_mortgage, date: dates[0], amount: 111.11)
            create(:cash_transaction, cash_transaction_category: rent_or_mortgage, date: dates[1], amount: 111.11)
            create(:cash_transaction, cash_transaction_category: rent_or_mortgage, date: dates[2], amount: 111.11)

            # add monthly equivalent regular transaction of 333.33
            create(:housing_cost, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "three_monthly", amount: 1000.00)
          end

          # NOTE: expected API use cases should not add both bank and regular transactions
          it "sums monthly bank, regular and cash transactions" do
            expect(gross_housing_costs).to eq 555.55 # 111.11 + 111.11 + 333.33
          end
        end
      end

      describe "#monthly_housing_benefit" do
        subject(:monthly_housing_benefit) { instance.monthly_housing_benefit }

        context "with state_benefits of housing_benefit type" do
          let(:dependants) { [] }

          before do
            create(:state_benefit,
                   state_benefit_type: build(:state_benefit_type, label: "housing_benefit"),
                   gross_income_summary: assessment.applicant_gross_income_summary,
                   state_benefit_payments: [
                     build(:state_benefit_payment, amount: 222.22, payment_date: dates[0]),
                     build(:state_benefit_payment, amount: 222.22, payment_date: dates[2]),
                   ])
          end

          it "returns monthly equivalent" do
            expect(monthly_housing_benefit).to eq 148.15 # (222.22 + 222.22) / 3
          end
        end

        context "with regular_transactions of housing_benefit type" do
          let(:dependants) { [] }

          before do
            create(:housing_benefit_regular, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "three_monthly", amount: 1000.00)
          end

          it "returns monthly equivalent" do
            expect(monthly_housing_benefit).to eq 333.33 # 1000.00 / 3
          end
        end
      end

      describe "#net_housing_costs" do
        subject(:net_housing_costs) { instance.net_housing_costs }

        context "when single, with no dependants" do
          let(:dependants) { [] }

          it "returns gross housing cost less benefits" do
            create(:housing_cost, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "monthly", amount: 1000.00)
            create(:housing_benefit_regular, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "monthly", amount: 500.00)

            expect(net_housing_costs).to eq 500.00
          end

          it "implements a cap" do
            create(:housing_cost, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "monthly", amount: 1000.00)
            create(:housing_benefit_regular, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "monthly", amount: 400.00)

            expect(net_housing_costs).to eq 545.00
          end
        end

        context "when has dependants and receives housing benefit" do
          let(:dependants) { build_list(:dependant, 1, :child_relative, submission_date: assessment.submission_date) }

          it "returns gross housing cost less benefits" do
            create(:housing_cost, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "monthly", amount: 1000.00)
            create(:housing_benefit_regular, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "monthly", amount: 500.00)

            expect(net_housing_costs).to eq 500.00
          end
        end

        # NOTE: when has dependants without benefits
        # or when not single and with no dependants??
        #
        context "when any other situation" do
          let(:dependants) { build_list(:dependant, 1, :child_relative, submission_date: assessment.submission_date) }

          it "returns gross housing without a cap" do
            create(:housing_cost, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "monthly", amount: 1000.00)
            create(:housing_benefit_regular, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "monthly", amount: 400.00)

            expect(net_housing_costs).to eq 600.00
          end
        end
      end
    end
  end
end
