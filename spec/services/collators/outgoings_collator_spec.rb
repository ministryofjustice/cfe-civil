require "rails_helper"

module Collators
  RSpec.describe OutgoingsCollator, :calls_bank_holiday do
    let(:assessment) { create :assessment, :with_everything }

    subject(:collator) do
      described_class.call(submission_date: assessment.submission_date,
                           person: instance_double(PersonWrapper, single?: true,
                                                                  dependants: []),
                           gross_income_summary: assessment.applicant_gross_income_summary,
                           disposable_income_summary: assessment.applicant_disposable_income_summary,
                           eligible_for_childcare: true,
                           allow_negative_net: true)
    end

    describe ".call" do
      it "calls all the collators and calculators" do
        expect(Collators::ChildcareCollator).to receive(:call).exactly(1).and_call_original
        expect(Collators::DependantsAllowanceCollator).to receive(:call).exactly(1).and_call_original
        expect(Collators::MaintenanceCollator).to receive(:call).with(assessment.applicant_disposable_income_summary.maintenance_outgoings).exactly(1).and_call_original
        expect(Collators::HousingCostsCollator).to receive(:call).exactly(1).and_call_original
        expect(Collators::LegalAidCollator).to receive(:call).with(assessment.applicant_disposable_income_summary.legal_aid_outgoings).exactly(1).and_call_original
        collator
      end
    end
  end
end
