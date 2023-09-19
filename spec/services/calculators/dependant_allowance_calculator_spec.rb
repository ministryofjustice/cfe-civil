require "rails_helper"

module Calculators
  RSpec.describe DependantAllowanceCalculator do
    describe "#call" do
      let(:submission_date) { Date.current }

      subject(:calculator) do
        described_class.call(
          dependant, submission_date
        )
      end

      context "when mocking Threshold values" do
        before do
          allow(Threshold).to receive(:value_for).with(:dependant_allowances, at: submission_date).and_return(
            {
              child_under_14: 211.00,
              child_under_15: 111.11,
              child_aged_15: 222.22,
              child_16_and_over: 333.33,
              adult: 444.44,
              adult_capital_threshold: 8_000,
            },
          )
        end

        context "under 15" do
          context "with income" do
            let(:dependant) { build :dependant, :under15, income_amount: 25.00, submission_date: }

            it "returns the child under 15 allowance and subtract the income" do
              expect(calculator).to eq 86.11
            end
          end

          context "under 14" do
            let(:dependant) { build :dependant, :under14, income_amount: 10.00, submission_date: }

            it "returns the child under 14 allowance and subtract the income" do
              expect(calculator).to eq 201
            end
          end

          context "without income" do
            let(:dependant) { build :dependant, :under15, income_amount: 0.0, submission_date: }

            it "returns the child under 15 allowance" do
              expect(calculator).to eq 111.11
            end
          end
        end

        context "15 years old" do
          context "with income" do
            let(:dependant) { build :dependant, :aged15, income_amount: 25.50, submission_date: }

            it "returns the aged 15 allowance less the monthly income" do
              expect(calculator).to eq(222.22 - 25.50)
            end
          end

          context "with income greater than the allowance" do
            let(:dependant) { build :dependant, :aged15, income_amount: 250.00, submission_date: }

            it "returns zero" do
              expect(calculator).to be_zero
            end
          end

          context "without income" do
            let(:dependant) { build :dependant, :aged15, income_amount: 30.55, submission_date: }

            it "returns the aged 15 allowance less the monthly income" do
              expect(calculator).to eq(222.22 - 30.55)
            end
          end
        end

        context "16 or 17 years old" do
          context "in full time education" do
            let(:assessment) { build(:assessment) }

            context "with  no income" do
              let(:dependant) { build :dependant, :aged16or17, income_amount: 0.0, in_full_time_education: true, submission_date: }

              it "returns the child 16 or over allowance with no income deduction" do
                expect(calculator).to eq 333.33
              end
            end

            context "with income" do
              let(:dependant) { build :dependant, :aged16or17, income_amount: 100.01, in_full_time_education: true, submission_date: }

              it "returns the child 16 or over with no income deduction" do
                expect(calculator).to eq(333.33 - 100.01)
              end
            end

            context "with income greater than the allowance" do
              let(:dependant) { build :dependant, :aged16or17, income_amount: 350.00, in_full_time_education: true, submission_date: }

              it "returns zero" do
                expect(calculator).to be_zero
              end
            end
          end

          context "not in full time education" do
            context "with  no income" do
              let(:dependant) { build :dependant, :aged16or17, income_amount: 0.0, in_full_time_education: false, submission_date: }

              it "returns the adult allowance with no income deduction" do
                expect(calculator).to eq 444.44
              end
            end

            context "with income" do
              let(:dependant) { build :dependant, :aged16or17, income_amount: 100.22, in_full_time_education: false, submission_date: }

              it "returns the adult allowance with no income deduction" do
                expect(calculator).to eq(444.44 - 100.22)
              end
            end
          end
        end

        context "over 18 years old" do
          context "with no income" do
            context "with capital assets < threshold" do
              let(:dependant) { build :dependant, :over18, income_amount: 0.0, assets_value: 4_470, submission_date: }

              it "returns the adult allowance with no deduction" do
                expect(calculator).to eq 444.44
              end
            end

            context "with capital assets > threshold" do
              let(:dependant) { build :dependant, :over18, income_amount: 0.0, assets_value: 8_100, submission_date: }

              it "returns the allowance of zero" do
                expect(calculator).to be_zero
              end
            end
          end

          context "with income" do
            context "with capital assets > threshold" do
              let(:dependant) { build :dependant, :over18, income_amount: 0.0, assets_value: 8_100, submission_date: }

              it "returns the allowance of zero" do
                expect(calculator).to eq 0.0
              end
            end
          end

          context "with capital assets < threshold" do
            let(:dependant) { build :dependant, :over18, income_amount: 203.37, assets_value: 5_000, submission_date: }

            it "returns the adult allowance with income deducted" do
              expect(calculator).to eq(444.44 - 203.37)
            end
          end
        end
      end
    end
  end
end
