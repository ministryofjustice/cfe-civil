require "rails_helper"

module Calculators
  RSpec.describe IncomeContributionCalculator do
    subject(:calculator) { described_class.call(income, submission_date) }

    context "without MTR" do
      let(:submission_date) { Date.new(2023, 9, 23) }

      context "income below band a" do
        let(:income) { 312.0 }

        it "returns zero" do
          expect(calculator).to be_zero
        end
      end

      context "negative income" do
        let(:income) { -100.0 }

        it "returns zero" do
          expect(calculator).to be_zero
        end
      end

      context "income in band a" do
        let(:income) { 340.0 }
        # (340 - 311) * 35% = 10.15

        it "returns 35% of income less £311" do
          expect(calculator).to eq 10.15
        end
      end

      context "income in band b" do
        let(:income) { 611.43 }
        # 53.90 + ((611.43 - 465) * 45%) = 119.79

        it "returns £53.90 + 45% of income less £455.99" do
          expect(calculator).to eq 119.79
        end
      end

      context "income in band c" do
        let(:income) { 4_326.77 }
        # 121.85 + ((4_326.77 - 616) * 70%) = 2,719.39

        it "returns £121.85 + 70% of income less 616.99" do
          expect(calculator).to eq 2_719.39
        end
      end
    end

    context "with MTR" do
      let(:submission_date) { Date.new(2525, 9, 23) }

      context "income below band a" do
        let(:income) { 621.0 }

        it "returns zero" do
          expect(calculator).to be_zero
        end
      end

      context "income £30 above band a threshold" do
        let(:income) { 652.0 }

        it "returns zero as it is less than £20" do
          expect(calculator).to be_zero
        end
      end

      context "income £60 above band a threshold" do
        let(:income) { 682.0 }

        it "returns 40% of income less £622" do
          expect(calculator).to eq 24.00
        end
      end

      context "income £30 above band b threshold" do
        let(:income) { 760 }

        it "returns 60% of income over 730 plus the base value" do
          expect(calculator).to eq 0.4 * (730 - 622) + 18
        end
      end

      context "income £30 over band c threshold" do
        let(:income) { 868 }

        it "returns 80% of income over 838 plus the base value" do
          expect(calculator).to eq 0.4 * (730 - 622) + 0.6 * (838 - 730) + 24
        end
      end

      context "income £30 over band z threshold" do
        let(:income) { 976 }

        it "returns the maximum value" do
          expect(calculator).to eq 0.4 * (730 - 622) + 0.6 * (838 - 730) + 0.8 * (946 - 838)
        end
      end
    end
  end
end
