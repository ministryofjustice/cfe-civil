require "rails_helper"

module Collators
  RSpec.describe MaintenanceCollator, :calls_bank_holiday do
    let(:assessment) { create :assessment, :with_disposable_income_summary }
    let(:disposable_income_summary) { assessment.applicant_disposable_income_summary }

    describe ".call" do
      subject(:collator) { described_class.call(maintenance_outgoings) }

      context "when there are no maintenance outgoings" do
        let(:maintenance_outgoings) { [] }

        it "leaves the monthly maintenance field on the disposable income summary as zero" do
          expect(collator).to be_zero
        end
      end

      context "when there are maintenance outgoings" do
        let(:maintenance_outgoings) do
          [
            # payments every 28 days which equals 112.08 per calendar month
            build(:maintenance_outgoing,  payment_date: 2.days.ago, amount: 103.46),
            build(:maintenance_outgoing,  payment_date: 30.days.ago, amount: 103.46),
            build(:maintenance_outgoing,  payment_date: 58.days.ago, amount: 103.46),
          ]
        end

        it "calculates the monthly equivalent" do
          expect(collator).to eq 112.08
        end
      end
    end
  end
end
