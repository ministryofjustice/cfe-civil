require "rails_helper"

module Utilities
  RSpec.describe ProceedingTypeThresholdPopulator do
    describe "#call" do
      let(:proceeding_types) do
        [
          build(:proceeding_type, ccms_code: "DA001", client_involvement_type: "A"),
          build(:proceeding_type, ccms_code: "DA005", client_involvement_type: "Z"),
          build(:proceeding_type, ccms_code: "SE014", client_involvement_type: "A"),
        ]
      end
      let(:assessment) { build :assessment, submission_date: Date.new(2022, 7, 12) }
      let(:response) do
        {
          request_id: "ba7de3c7-cfbe-43de-89b6-8afa2fbe4193",
          success: true,
          proceedings: [
            {
              ccms_code: "DA001",
              client_involvement_type: "A",
              gross_income_upper: true,
              disposable_income_upper: true,
              capital_upper: true,
              matter_type: "Domestic abuse",
            },
            {
              ccms_code: "DA005",
              client_involvement_type: "Z",
              gross_income_upper: false,
              disposable_income_upper: false,
              capital_upper: false,
              matter_type: "Domestic abuse",
            },
            {
              ccms_code: "SE014",
              client_involvement_type: "A",
              gross_income_upper: false,
              disposable_income_upper: false,
              capital_upper: false,
              matter_type: "Children - section 8",
            },
          ],
        }
      end
      let(:expected_payload) do
        [
          {
            ccms_code: "DA001",
            client_involvement_type: "A",
          },
          {
            ccms_code: "DA005",
            client_involvement_type: "Z",
          },
          {
            ccms_code: "SE014",
            client_involvement_type: "A",
          },
        ]
      end

      it "calls LegalFrameworkAPI::ThresholdWaivers with expected payload" do
        expect(LegalFrameworkAPI::ThresholdWaivers).to receive(:call).with(expected_payload)
        allow(LegalFrameworkAPI::ThresholdWaivers).to receive(:call).and_return(response)

        described_class.certificated(proceeding_types:,
                                     submission_date: assessment.submission_date)
      end

      it "updates the threshold values on the proceeding type records where the threshold is not waived" do
        allow(LegalFrameworkAPI::ThresholdWaivers).to receive(:call).and_return(response)

        described_class.certificated(proceeding_types:,
                                     submission_date: assessment.submission_date)

        pt = proceeding_types.detect { _1.ccms_code == "DA005" }
        expect(pt.gross_income_upper_threshold).to eq 2657.0
        expect(pt.disposable_income_upper_threshold).to eq 733.0
        expect(pt.capital_upper_threshold).to eq 8000.0

        pt = proceeding_types.detect { _1.ccms_code == "SE014" }
        expect(pt.gross_income_upper_threshold).to eq 2657.0
        expect(pt.disposable_income_upper_threshold).to eq 733.0
        expect(pt.capital_upper_threshold).to eq 8000.0
      end

      it "updates threshold values on proceeding type records where the threshold is waived" do
        allow(LegalFrameworkAPI::ThresholdWaivers).to receive(:call).and_return(response)

        described_class.certificated(proceeding_types:,
                                     submission_date: assessment.submission_date)

        pt = proceeding_types.detect { _1.ccms_code == "DA001" }
        expect(pt.gross_income_upper_threshold).to eq 999_999_999_999.0
        expect(pt.disposable_income_upper_threshold).to eq 999_999_999_999.0
        expect(pt.capital_upper_threshold).to eq 999_999_999_999.0
      end

      context "for controlled work" do
        it "ignores waivers" do
          expect(LegalFrameworkAPI::ThresholdWaivers).not_to receive(:call)

          described_class.controlled(proceeding_types:,
                                     submission_date: assessment.submission_date)

          pt = proceeding_types.detect { _1.ccms_code == "DA001" }
          expect(pt.gross_income_upper_threshold).to eq 2657.0
          expect(pt.disposable_income_upper_threshold).to eq 733.0
          expect(pt.capital_upper_threshold).to eq 8000.0
        end
      end

      context "for certificated upper tribunal work" do
        let(:proceeding_types) { build_list(:proceeding_type, 1, ccms_code: "IM030", client_involvement_type: "A") }

        it "ignores waivers" do
          expect(LegalFrameworkAPI::MockThresholdWaivers).not_to receive(:call)

          described_class.certificated(proceeding_types:,
                                       submission_date: assessment.submission_date)

          pt = proceeding_types.detect { _1.ccms_code == "IM030" }
          expect(pt.gross_income_upper_threshold).to eq 2657.0
          expect(pt.disposable_income_upper_threshold).to eq 733.0
          expect(pt.capital_upper_threshold).to eq 8000.0
        end
      end
    end
  end
end
