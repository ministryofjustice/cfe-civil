require "rails_helper"

module Calculators
  RSpec.describe MonthlyIncomeConverter do
    subject(:converter) { described_class.new(frequency, payments) }

    let(:payments) { [203.44, 205.00, 205.00] }

    context "monthly" do
      let(:frequency) { :monthly }

      describe "monthly_amount" do
        it "returns the average monthly amount" do
          expect(converter.monthly_amount).to eq 204.48
        end
      end
    end

    context "four_weekly" do
      let(:frequency) { :four_weekly }

      describe "monthly_amount" do
        it "returns the average for the calendar month" do
          expect(converter.monthly_amount).to eq 221.52
        end
      end
    end

    context "two_weekly" do
      let(:frequency) { :two_weekly }

      describe "monthly_amount" do
        it "returns the average for the calendar month" do
          expect(converter.monthly_amount).to eq 443.04
        end
      end
    end

    context "weekly" do
      let(:frequency) { :weekly }

      describe "monthly_amount" do
        it "returns the average for the calendar month" do
          expect(converter.monthly_amount).to eq 886.08
        end
      end
    end

    context "unknown" do
      let(:frequency) { :unknown }
      let(:payments) { [203.44, 205.00, 205.00, 178.77, 290.12] }

      describe "monthly_amount" do
        it "returns the sum of payments divided by 3" do
          expect(converter.monthly_amount).to eq 360.78
        end
      end
    end

    context "Unrecognized frequency" do
      let(:frequency) { :abcd }

      it "raises an error" do
        expect { converter.monthly_amount }.to raise_error("Unrecognized frequency")
      end
    end
  end
end
