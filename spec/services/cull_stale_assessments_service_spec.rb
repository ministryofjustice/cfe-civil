require "rails_helper"

RSpec.describe CullStaleAssessmentsService do
  describe ".call" do
    subject(:cull_stale_assessment) { described_class.call }

    let!(:assessment) do
      travel_to creation_date
      assessment = create_assessment_and_associated_records
      travel_back
      assessment
    end

    context "when assessments created more than two weeks ago" do
      let(:creation_date) { (CFEConstants::STALE_ASSESSMENT_THRESHOLD_DAYS + 1).days.ago }

      it "deletes the assessment and all associated records" do
        cull_stale_assessment

        expect(Assessment.exists?(assessment.id)).to be false
      end
    end

    context "when assessments created less than two weeks ago" do
      let(:creation_date) { (CFEConstants::STALE_ASSESSMENT_THRESHOLD_DAYS - 1).days.ago }

      it "does not delete any records" do
        cull_stale_assessment

        expect(Assessment.exists?(assessment.id)).to be true
      end
    end
  end

  def create_assessment_and_associated_records
    create(:assessment)
  end
end
