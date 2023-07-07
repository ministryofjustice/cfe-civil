require "rails_helper"

module Calculators
  RSpec.describe ChildcareEligibilityCalculator do
    describe "#call" do
      let(:dependants) { [] }
      let(:applicant) { OpenStruct.new(in_work?: true, is_student?: false) }
      let(:partner) { nil }
      let(:submission_date) { 1.year.ago }

      subject(:calculated_result) { described_class.call(applicants: [applicant, partner].compact, dependants:, submission_date:) }

      context "with no dependants, an employed applicant and no partner" do
        it "returns false" do
          expect(calculated_result).to eq false
        end
      end

      context "with child dependants, an employed applicant and no partner" do
        let(:dependants) { [instance_double(Dependant, becomes_16_on: submission_date + 1.year)] }

        it "returns true" do
          expect(calculated_result).to eq true
        end
      end

      context "with child dependants, a student applicant and no partner" do
        let(:dependants) { [instance_double(Dependant, becomes_16_on: submission_date + 1.year)] }
        let(:applicant) { OpenStruct.new(in_work?: false, is_student?: true) }

        it "returns true" do
          expect(calculated_result).to eq true
        end
      end

      context "with adult dependants, an employed applicant and no partner" do
        let(:dependants) { [OpenStruct.new(becomes_16_on: submission_date - 1.year)] }

        it "returns true" do
          expect(calculated_result).to eq false
        end
      end

      context "with child dependants, an employed applicant and an employed partner" do
        let(:dependants) { [OpenStruct.new(becomes_16_on: submission_date + 1.year)] }
        let(:partner) { OpenStruct.new(in_work?: true, is_student?: false) }

        it "returns true" do
          expect(calculated_result).to eq true
        end
      end

      context "with child dependants, an employed applicant and an unemployed partner" do
        let(:dependants) { [OpenStruct.new(becomes_16_on: submission_date + 1.year)] }
        let(:partner) { OpenStruct.new(in_work?: false, is_student?: false) }

        it "returns true" do
          expect(calculated_result).to eq false
        end
      end
    end
  end
end
