require "rails_helper"

module Collators
  RSpec.describe HousingCostsCollator, :calls_bank_holiday do
    let(:assessment) { create :assessment }
    let(:disposable_income_summary) { assessment.applicant_disposable_income_summary }
    let(:gross_income_summary) { assessment.applicant_gross_income_summary }
    let(:housing_benefit_type) { create :state_benefit_type, label: "housing_benefit" }
    let(:submission_date) { assessment.submission_date }

    subject(:collator) do
      described_class.call(housing_cost_outgoings:,
                           regular_transactions: [],
                           person: instance_double(PersonWrapper, single?: true, dependants: []),
                           housing_benefit:,
                           cash_transactions:,
                           submission_date: assessment.submission_date,
                           allow_negative_net: false)
    end

    describe ".call" do
      context "with no housing cost outgoings" do
        let(:housing_cost_outgoings) { [] }
        let(:cash_transactions) { [] }

        context "without housing benefit" do
          let(:housing_benefit) { 0 }

          it "has expected housing cost attributes" do
            collator
            expect(collator)
              .to have_attributes(
                housing_costs: 0.0,
                allowed_housing_costs: 0.0,
              )
          end
        end

        context "with housing benefit as a state_benefit" do
          let(:housing_benefit) { 101.02 }

          it "has expected housing cost attributes" do
            expect(collator)
              .to have_attributes(
                housing_costs: 0.0,
                allowed_housing_costs: 0,
              )
          end
        end
      end

      context "with housing cost outgoings" do
        let(:cash_transactions) { [] }
        let(:housing_cost_outgoings) do
          [build(:housing_cost_outgoing, amount: 355.44, payment_date: Date.current, housing_cost_type:),
           build(:housing_cost_outgoing, amount: 355.44, payment_date: 1.month.ago, housing_cost_type:),
           build(:housing_cost_outgoing, amount: 355.44, payment_date: 2.months.ago, housing_cost_type:)]
        end

        context "without housing benefit" do
          let(:housing_benefit) { 0 }

          context "with board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }

            it "records half the monthly housing cost" do
              expect(collator)
                .to have_attributes(
                  housing_costs: 177.72,
                  allowed_housing_costs: 177.72,
                )
            end
          end

          context "with rent" do
            let(:housing_cost_type) { "rent" }

            it "records the full monthly housing costs" do
              expect(collator)
                .to have_attributes(
                  housing_costs: 355.44,
                  allowed_housing_costs: 355.44,
                )
            end
          end
        end

        xcontext "with housing benefit as a state_benefit" do
          let(:housing_benefit) { 101.02 }

          context "with board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }

            it "records half the housing cost less the housing benefit" do
              expect(collator)
                .to have_attributes(
                  housing_costs: 177.72,
                  allowed_housing_costs: 76.70, # 177.72 - 101.02
                )
            end
          end

          context "with mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "records the full housing costs less the housing benefit" do
              expect(collator)
                .to have_attributes(
                  housing_costs: 355.44,
                  allowed_housing_costs: 254.42, # 355.44 - 101.02
                )
            end
          end
        end

        context "with weekly housing benefit" do
          let(:housing_benefit) { 500.00 }
          let(:housing_cost_type) { "rent" }

          it "records the full monthly housing costs" do
            expect(collator).to have_attributes(housing_costs: 355.44)
          end
        end
      end

      xcontext "with cash payments" do
        let(:housing_cost_outgoings) { [] }
        let(:housing_benefit) { 0 }

        let(:cash_transactions) do
          build_list(:cash_transaction, 1, category: :rent_or_mortgage, operation: :debit, amount: 564)
        end

        it "caps the net costs" do
          expect(collator)
            .to have_attributes(housing_costs: 564.00,
                                allowed_housing_costs: 545.00) # Cap applied
        end
      end
    end
  end
end
