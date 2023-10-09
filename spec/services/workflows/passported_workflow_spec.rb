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
    let(:applicant_capital_summary) { assessment.applicant_capital_summary }
    let(:gross_income_summary) { assessment.applicant_gross_income_summary }
    let(:capital_data) do
      PersonCapitalSubtotals.unassessed(vehicles: [], properties: [])
    end

    describe ".call" do
      subject(:workflow_call) do
        described_class.call(proceeding_types: assessment.reload.proceeding_types,
                             capitals_data: CapitalsData.new(vehicles: [], liquid_capital_items: [], non_liquid_capital_items: [], main_home: nil, additional_properties: []),
                             date_of_birth: applicant.date_of_birth,
                             submission_date: assessment.submission_date,
                             level_of_help: assessment.level_of_help,
                             receives_asylum_support: applicant.receives_asylum_support)
      end

      it "calls Capital collator and return some data" do
        allow(Collators::CapitalCollator).to receive(:call).and_return(capital_data)
        expect(Collators::CapitalCollator).to receive(:call)
        expect(workflow_call.capital_subtotals.applicant_capital_subtotals).to eq capital_data
        expect(workflow_call.capital_subtotals.combined_assessed_capital).to eq capital_data.assessed_capital
      end

      it "calls CapitalSummarizer and updates capital summary record with result" do
        allow(Collators::CapitalCollator).to receive(:call).and_return(capital_data)
        expect(workflow_call.capital_subtotals.summarized_assessment_result).to eq :eligible
      end
    end
  end
end
