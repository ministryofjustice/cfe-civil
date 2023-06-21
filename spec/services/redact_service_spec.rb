require "rails_helper"

describe RedactService do
  before do
    create(:request_log,
           request: {
             assessment: {
               submission_date: "2023-05-08",
             },
             applicant: {
               date_of_birth: "1970-01-01",
             },
             something: 27,
             details: %w[string],
             something_else: {
               payments: [{ client_id: "2345" }],
             },
           })
    described_class.call
  end

  context "when filtering log requests" do
    let(:request_log) { RequestLog.last }

    it "redacts client ids and dates of birth" do
      expect(request_log.request.deep_symbolize_keys)
        .to eq({
          assessment: {
            submission_date: "2023-05-08",
          },
          applicant: {
            date_of_birth: "1969-05-08",
          },
          something: 27,
          details: %w[string],
          something_else: { payments: [{ client_id: "** REDACTED **" }] },
        })
    end
  end
end
