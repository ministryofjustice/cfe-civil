require "rails_helper"

RSpec.describe RequestLog do
  context "scopes" do
    describe ".with_client_reference" do
      before do
        create(:request_log, request: { assessment: { client_reference_id: nil } })
        create(:request_log, request: { assessment: { client_reference_id: "client_reference_id" } })
        create(:request_log, request: { applicant: {} })
      end

      it "return request_logs filtered by client_reference_id" do
        expect(described_class.with_client_reference.count).to eq 1
      end
    end
  end
end
