require "rails_helper"

module Workflows
  RSpec.describe PassportedWorkflow do
    let!(:assessment) do
      create :assessment,
             :with_disposable_income_summary,
             :with_gross_income_summary,
             :with_capital_summary,
             proceedings: [%w[DA003 A], %w[SE014 Z]]
    end
    let(:applicant) { build :applicant, :with_qualifying_benefits }
    let(:unassessed_capital) do
      PersonCapitalSubtotals.unassessed(vehicles: [], properties: [])
    end
    let(:no_capital) do
      CapitalsData.new(vehicles: [], liquid_capital_items: [], non_liquid_capital_items: [], main_home: nil, additional_properties: [])
    end

    describe ".call" do
      subject(:workflow_call) do
        described_class.without_partner(capitals_data: no_capital,
                                        date_of_birth: applicant.date_of_birth,
                                        submission_date: assessment.submission_date,
                                        level_of_help: assessment.level_of_help)
      end

      it "calls Capital collator and return some data" do
        allow(Collators::CapitalCollator).to receive(:call).and_return(unassessed_capital)
        expect(Collators::CapitalCollator).to receive(:call)
        expect(workflow_call.capital_subtotals.applicant_capital_subtotals).to eq unassessed_capital
        expect(workflow_call.capital_subtotals.combined_assessed_capital).to eq unassessed_capital.assessed_capital
      end
    end
  end
end
