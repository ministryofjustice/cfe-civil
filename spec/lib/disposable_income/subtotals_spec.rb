require "rails_helper"

module DisposableIncome
  RSpec.describe Subtotals do
    let(:assessment) { create(:assessment, submission_date: Date.new(2525, 4, 25)) }
    let(:subtotals) do
      described_class.new(
        partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.blank,
        applicant_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new(
          total_gross_income: 652,
          disposable_employment_deductions: 0,
          outgoings: Collators::OutgoingsCollator::Result.blank,
          partner_allowance: 0,
          regular: Collators::RegularOutgoingsCollator::Result.blank,
          disposable: Collators::DisposableIncomeCollator::Result.blank,
        ),
        submission_date: assessment.submission_date,
        level_of_help: assessment.level_of_help,
      )
    end

    context "when income contribution under £20" do
      it "returns eligible" do
        expect(subtotals.summarized_assessment_result(assessment.proceeding_types)).to eq(:eligible)
      end
    end
  end
end
