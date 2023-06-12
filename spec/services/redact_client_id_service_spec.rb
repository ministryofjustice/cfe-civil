require "rails_helper"

describe RedactClientIdService do
  before do
    create(:request_log,
           request: {
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

    it "redacts client ids" do
      expect(request_log.request.deep_symbolize_keys)
        .to eq({ something: 27,
                 details: %w[string],
                 something_else: { payments: [{ client_id: "** REDACTED **" }] } })
    end
  end
end
