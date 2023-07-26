require "rails_helper"

describe RedactService do
  context "when filtering log request" do
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

  context "when filtering log response" do
    let(:request_log) { RequestLog.last }

    context "successful response" do
      before do
        create(:request_log, response: {
          version: "6",
          timestamp: "2023-07-07T15:32:12.757Z",
          success: true,
        })
        described_class.call
      end

      it "returns timestamp attribute in response" do
        expect(request_log.response.deep_symbolize_keys).to be_key(:timestamp)
      end

      it "redacts time in timestamp" do
        expect(request_log.response.deep_symbolize_keys[:timestamp]).to eq("2023-07-07")
      end
    end

    context "successful response with assessment remarks" do
      before do
        create(:request_log, :with_response_remarks)
        described_class.call
      end

      it "redacts client_ids in assessment remarks" do
        expect(request_log.response.deep_symbolize_keys[:assessment][:remarks]).to eq({
          employment_tax: {
            refunds: [
              "** REDACTED **",
            ],
          },
          employment_nic: {
            refunds: [
              "** REDACTED **",
            ],
          },
          state_benefit_payment: {
            unknown_frequency: [
              "** REDACTED **",
              "** REDACTED **",
            ],
            multi_benefit: [
              "** REDACTED **",
            ],
          },
          other_income_payment: {
            unknown_frequency: [
              "** REDACTED **",
            ],
          },
          outgoings_housing_cost: {
            unknown_frequency: [
              "** REDACTED **",
            ],
          },
          employment_payment: {
            unknown_frequency: [
              "** REDACTED **",
              "** REDACTED **",
            ],
          },
          policy_disregards: [
            "** REDACTED **",
          ],
        })
      end
    end

    context "error response" do
      before do
        create(:request_log, :error)
        described_class.call
      end

      it "missing timestamp attribute in response" do
        expect(request_log.response.deep_symbolize_keys).not_to be_key(:timestamp)
      end
    end
  end
end
