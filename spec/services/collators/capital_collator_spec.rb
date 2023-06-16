require "rails_helper"

module Collators
  RSpec.describe CapitalCollator do
    let(:assessment) { create :assessment, :with_capital_summary, :with_disposable_income_summary }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:submission_date) { assessment.submission_date }
    let(:capital_summary) { assessment.applicant_capital_summary }
    let(:today) { Date.new(2019, 4, 2) }
    let(:pcd_value) { 0 }
    let(:smod_value) { 0 }
    let(:level_of_help) { "controlled" }
    let(:vehicles) { [] }

    describe "#call" do
      subject(:collator) do
        described_class.call submission_date: assessment.submission_date,
                             capital_summary: assessment.applicant_capital_summary,
                             vehicles:,
                             pensioner_capital_disregard: pcd_value,
                             maximum_subject_matter_of_dispute_disregard: smod_value,
                             level_of_help:
      end

      context "liquid capital" do
        before do
          capital_summary
            .liquid_capital_items
            .build([
              attributes_for(:liquid_capital_item, value: 145.83),
            ])
        end

        it "calls LiquidCapitalAssessment and updates capital summary with the result" do
          expect(collator.total_liquid).to eq 145.83
        end
      end

      context "property_assessment" do
        before do
          create :property, :main_home, capital_summary: assessment.applicant_capital_summary
        end

        it "instantiates and calls the Property Assessment service" do
          property_result = Assessors::PropertyAssessor::Result.new(assessed_equity: 23_000.0,
                                                                    property: assessment.applicant_capital_summary.main_home,
                                                                    smod_allowance: 0)
          allow(Assessors::PropertyAssessor).to receive(:call).and_return([property_result])
          expect(collator.total_property).to eq 23_000.0
        end
      end

      context "with a main home and an additional property" do
        let(:smod_value) { 60_000 }
        let(:vehicles) do
          [
            build(:vehicle, subject_matter_of_dispute: true, value: 15_000, in_regular_use: false),
            build(:vehicle, subject_matter_of_dispute: false, value: 3_500, in_regular_use: false),
          ]
        end

        before do
          capital_summary
            .properties
            .build([
              attributes_for(:property, main_home: true, subject_matter_of_dispute: true,
                                        value: 280_000, outstanding_mortgage: 50_000),
              attributes_for(:property, main_home: false, value: 250_000, outstanding_mortgage: 243_000),
            ])
          capital_summary
            .non_liquid_capital_items
            .build([
              attributes_for(:non_liquid_capital_item, subject_matter_of_dispute: true, value: 3_000),
              attributes_for(:non_liquid_capital_item, subject_matter_of_dispute: false, value: 8_000),
            ])
          capital_summary
            .liquid_capital_items
            .build([
              attributes_for(:liquid_capital_item, subject_matter_of_dispute: true, value: 4_000),
              attributes_for(:liquid_capital_item, subject_matter_of_dispute: false, value: 12_000),
            ])
        end

        it "produces total non disputed and total disputed (minus SMOD) assets" do
          # disputed property value is 280k - 50k mortgage - 60k SMOD - 100k main home allowance = 70k (hopefully)
          expect(total_non_disputed_capital: collator.total_non_disputed_capital.to_f,
                 total_disputed_capital: collator.total_disputed_capital.to_f)
            .to eq(total_non_disputed_capital: 7_000.0 + 3_500 + 8_000 + 12_000,
                   total_disputed_capital: 70_000.0 + 15_000 + 3_000 + 4_000)
        end
      end

      context "vehicle assessment" do
        let(:vehicles) do
          [build(:vehicle, value: 2_500, in_regular_use: false)]
        end

        it "instantiates and calls the Vehicle Assesment service" do
          expect(collator.total_vehicle).to eq 2_500.0
        end
      end

      context "non_liquid_capital_assessment" do
        before do
          capital_summary
            .non_liquid_capital_items
            .build([
              attributes_for(:non_liquid_capital_item, value: 500),
            ])
        end

        it "instantiates and calls NonLiquidCapitalAssessment" do
          expect(collator.total_non_liquid).to eq 500.0
        end
      end

      context "summarization of result_fields" do
        let(:pcd_value) { 100_000 }
        let(:vehicles) do
          [
            build(:vehicle, value: 2_500, in_regular_use: false),
          ]
        end

        before do
          capital_summary
            .properties
            .build([
              attributes_for(:property, :main_home),
            ])
          capital_summary
            .liquid_capital_items
            .build([
              attributes_for(:liquid_capital_item, value: 145.83),
            ])
          capital_summary
            .non_liquid_capital_items
            .build([
              attributes_for(:non_liquid_capital_item, value: 500),
            ])
        end

        it "summarizes the results it gets from the subservices" do
          property_result = Assessors::PropertyAssessor::Result.new(assessed_equity: 23_000.0,
                                                                    property: assessment.applicant_capital_summary.main_home,
                                                                    smod_allowance: 0)

          allow(Assessors::PropertyAssessor).to receive(:call).and_return([property_result])

          expect(collator.total_liquid.to_f).to eq 145.83
          expect(collator.total_non_liquid).to eq 500
          expect(collator.total_vehicle).to eq 2_500
          expect(collator.total_property).to eq 23_000
          expect(collator.total_mortgage_allowance).to eq 999_999_999_999
          expect(collator.total_capital.to_f).to eq 26_145.83
          expect(collator.pensioner_capital_disregard).to eq 100_000
          expect(collator.subject_matter_of_dispute_disregard).to eq 0
          expect(collator.assessed_capital).to eq(-0.0)
          expect(collator.pensioner_disregard_applied.to_f).to eq(26_145.83)
        end
      end
    end
  end
end
