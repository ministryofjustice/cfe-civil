require "rails_helper"
require Rails.root.join("spec/fixtures/assessment_request_fixture.rb")

RSpec.describe Assessment, type: :model do
  let(:payload) { AssessmentRequestFixture.json }

  context "version 6" do
    let(:param_hash) do
      {
        client_reference_id: "client-ref-1",
        submission_date: Date.current,
        remote_ip: "127.0.0.1",
      }
    end

    it "writes current date into the date column" do
      assessment = described_class.create! param_hash
      expect(assessment.created_at).to eq(Date.current)
      expect(assessment.updated_at).to eq(Date.current)
    end
  end

  context "missing ip address" do
    let(:param_hash) do
      {
        client_reference_id: "client-ref-1",
        submission_date: Date.current,
      }
    end

    it "errors" do
      assessment = described_class.create param_hash
      expect(assessment.persisted?).to be false
      expect(assessment.valid?).to be false
      expect(assessment.errors.full_messages).to include("Remote ip can't be blank")
    end
  end
end
