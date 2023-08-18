require "rails_helper"

RSpec.describe RequestLog do
  before do
    create(:request_log, request: { assessment: { client_reference_id: nil } }, created_at: Date.new(2017, 2, 25))
    create(:request_log, request: { assessment: { client_reference_id: "client_reference_id" } }, created_at: Date.new(2018, 6, 15))
    create(:request_log, request: { applicant: {} }, created_at: Date.new(2023, 5, 30))
    create(:request_log, request: { assessment: { client_reference_id: nil } }, created_at: Date.new(2023, 5, 31))
  end

  context "scopes" do
    describe ".with_client_reference" do
      it "return request_logs filtered by client_reference_id" do
        expect(described_class.with_client_reference.count).to eq 1
      end
    end

    describe ".created_before" do
      around do |example|
        travel_to Date.new(2023, 6, 15)
        example.run
        travel_back
      end

      it "return request_logs filtered by created_at" do
        expect(described_class.created_before(5.years.ago.to_date).map { |s| s.created_at.to_s }).to match_array(%w[2017-02-25])
        expect(described_class.created_before(15.days.ago.to_date).map { |s| s.created_at.to_s }).to match_array(%w[2017-02-25 2018-06-15 2023-05-30])
      end
    end
  end
end
