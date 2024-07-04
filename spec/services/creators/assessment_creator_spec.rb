require "rails_helper"

module Creators
  RSpec.describe AssessmentCreator do
    let(:remote_ip) { "127.0.0.1" }

    let(:raw_post) do
      {
        client_reference_id: "psr-123",
        submission_date: "2019-06-06",
      }
    end

    subject(:creator) { described_class.call(remote_ip:, assessment_params:) }

    context "version 6" do
      let(:assessment_params) { raw_post }

      context "valid request when level of representation is missing" do
        it "is successful" do
          expect(creator.success?).to be true
        end

        it "populates the assessment record with expected values" do
          assessment = creator.assessment
          expect(assessment.remote_ip).to eq "127.0.0.1"
          expect(creator.assessment.level_of_help).to eq "certificated"
        end

        it "has no errors" do
          expect(creator.errors).to be_empty
        end
      end

      context "valid request when level of representation is specified" do
        let(:assessment_params) { raw_post.merge(level_of_help:) }

        context "controlled" do
          let(:level_of_help) { "controlled" }

          it "sets the level appropriately" do
            expect(creator.success?).to be true
            expect(creator.assessment.level_of_help).to eq "controlled"
          end
        end

        context "certificated" do
          let(:level_of_help) { "certificated" }

          it "sets the level appropriately" do
            expect(creator.success?).to be true
            expect(creator.assessment.level_of_help).to eq "certificated"
          end
        end
      end

      context "invalid request" do
        let(:remote_ip) { nil }

        it "is not successful" do
          expect(creator.success?).to be false
        end

        it "has errors" do
          expect(creator.errors).to include("Remote ip can't be blank")
        end
      end
    end
  end
end
