require "rails_helper"

module Collators
  RSpec.describe HousingCostsCollator, :calls_bank_holiday do
    let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary }
    let(:disposable_income_summary) { assessment.applicant_disposable_income_summary }
    let(:gross_income_summary) { assessment.applicant_gross_income_summary }
    let(:housing_benefit_type) { create :state_benefit_type, label: "housing_benefit" }
    let(:submission_date) { assessment.submission_date }
    let(:rent_or_mortgage_category) { create(:rent_or_mortgage_transaction_category, gross_income_summary: assessment.applicant_gross_income_summary) }

    subject(:collator) do
      described_class.call(housing_cost_outgoings:,
                           person: instance_double(PersonWrapper, single?: true, dependants: []),
                           gross_income_summary: assessment.applicant_gross_income_summary,
                           submission_date: assessment.submission_date,
                           allow_negative_net: false)
    end

    describe "#housing_benefit" do
      subject(:housing_benefit) { collator.housing_benefit }
      let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }
      let(:housing_cost_outgoings) { [] }

      context "with state_benefits of housing_benefit type" do
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
          expect(housing_benefit).to eq 148.15 # (222.22 + 222.22) / 3
        end
      end

      context "with regular_transactions of housing_benefit type" do
        before do
          create(:housing_benefit_regular, gross_income_summary: assessment.applicant_gross_income_summary, frequency: "three_monthly", amount: 1000.00)
        end

        it "returns monthly equivalent" do
          expect(housing_benefit).to eq 333.33 # 1000.00 / 3
        end
      end
    end

    describe ".call" do
      context "with no housing cost outgoings" do
        let(:housing_cost_outgoings) { [] }

        context "without housing benefit" do
          it "has expected housing cost attributes" do
            collator
            expect(collator)
              .to have_attributes(
                gross_housing_costs: 0.0,
                housing_benefit: 0.0,
                net_housing_costs: 0.0,
              )
          end
        end

        context "with housing benefit as a state_benefit" do
          before do
            state_benefit = create :state_benefit, gross_income_summary:, state_benefit_type: housing_benefit_type
            create :state_benefit_payment, state_benefit:, amount: 101.02, payment_date: Date.current
            create :state_benefit_payment, state_benefit:, amount: 101.02, payment_date: 1.month.ago
            create :state_benefit_payment, state_benefit:, amount: 101.02, payment_date: 2.months.ago
          end

          it "has expected housing cost attributes" do
            expect(collator)
              .to have_attributes(
                gross_housing_costs: 0.0,
                housing_benefit: 101.02,
                net_housing_costs: 0,
              )
          end
        end
      end

      context "with housing cost outgoings" do
        let(:housing_cost_outgoings) do
          [build(:housing_cost_outgoing, amount: 355.44, payment_date: Date.current, housing_cost_type:),
           build(:housing_cost_outgoing, amount: 355.44, payment_date: 1.month.ago, housing_cost_type:),
           build(:housing_cost_outgoing, amount: 355.44, payment_date: 2.months.ago, housing_cost_type:)]
        end

        context "without housing benefit" do
          context "with board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }

            it "records half the monthly housing cost" do
              expect(collator)
                .to have_attributes(
                  gross_housing_costs: 177.72,
                  housing_benefit: 0.0,
                  net_housing_costs: 177.72,
                )
            end
          end

          context "with rent" do
            let(:housing_cost_type) { "rent" }

            it "records the full monthly housing costs" do
              expect(collator)
                .to have_attributes(
                  gross_housing_costs: 355.44,
                  housing_benefit: 0.0,
                  net_housing_costs: 355.44,
                )
            end
          end
        end

        context "with housing benefit as a state_benefit" do
          before do
            state_benefit = create :state_benefit, gross_income_summary:, state_benefit_type: housing_benefit_type
            create :state_benefit_payment, state_benefit:, amount: 101.02, payment_date: Date.current
            create :state_benefit_payment, state_benefit:, amount: 101.02, payment_date: 1.month.ago
            create :state_benefit_payment, state_benefit:, amount: 101.02, payment_date: 2.months.ago
          end

          context "with board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }

            it "records half the housing cost less the housing benefit" do
              expect(collator)
                .to have_attributes(
                  gross_housing_costs: 177.72,
                  housing_benefit: 101.02,
                  net_housing_costs: 76.70, # 177.72 - 101.02
                )
            end
          end

          context "with mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "records the full housing costs less the housing benefit" do
              expect(collator)
                .to have_attributes(
                  gross_housing_costs: 355.44,
                  housing_benefit: 101.02,
                  net_housing_costs: 254.42, # 355.44 - 101.02
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
            expect(collator).to have_attributes(gross_housing_costs: 355.44, housing_benefit: 833.33)
          end
        end
      end

      context "with housing cost regular_transactions" do
        let(:housing_cost_outgoings) { [] }

        before do
          create(:regular_transaction, gross_income_summary:, operation: "debit", category: "rent_or_mortgage", frequency: "three_monthly", amount: 1000.00)
        end

        context "without housing benefit" do
          it "records the full monthly housing costs" do
            expect(collator)
              .to have_attributes(
                gross_housing_costs: 333.33,
                housing_benefit: 0.0,
                net_housing_costs: 333.33,
              )
          end
        end

        context "with housing benefit as a regular_transaction" do
          before do
            create(:regular_transaction, gross_income_summary:, operation: "credit", category: "housing_benefit", frequency: "three_monthly", amount: 1000.0)
          end

          it "records half the housing cost less the housing benefit" do
            expect(collator)
              .to have_attributes(
                gross_housing_costs: 333.33,
                housing_benefit: 333.33,
                net_housing_costs: 0.00,
              )
          end
        end
      end

      context "with cash payments" do
        let(:housing_cost_outgoings) { [] }

        before do
          create(:cash_transaction, cash_transaction_category: rent_or_mortgage_category, amount: 564)
        end

        it "caps the net costs" do
          expect(collator)
            .to have_attributes(gross_housing_costs: 564.00,
                                net_housing_costs: 545.00) # Cap applied
        end
      end
    end
  end
end
