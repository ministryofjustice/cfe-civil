require "rails_helper"

describe RedactService do
  describe "redact_dob" do
    it "really works on 29th February" do
      expect(described_class.redact_dob("2024-2-29", "1952-05-03")).to eq("1952-03-01")
    end
  end

  describe "filtering log request" do
    before do
      create(:request_log,
             request: {
               assessment: {
                 submission_date: "2023-05-08",
               },
               applicant: {
                 # 53 years old
                 date_of_birth: "1970-01-01",
               },
               dependants: [
                 # 19 years old
                 { date_of_birth: "2003-09-08" },
                 # exactly 16
                 { date_of_birth: "2007-05-08" },
               ],
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
          details: %w[string],
          applicant: {
            # still 53 years old
            date_of_birth: "1969-05-09",
          },
          something: 27,
          assessment: {
            submission_date: "2023-05-08",
          },
          dependants: [
            # still 19 years old
            { date_of_birth: "2003-05-09" },
            # unchanged
            { date_of_birth: "2007-05-08" },
          ],
          something_else: { payments: [{ client_id: "** REDACTED **" }] },
        })
    end
  end

  describe "filtering log response" do
    let(:request_log) { RequestLog.last }
    let(:response) { request_log.response.deep_symbolize_keys }

    context "successful response" do
      before do
        create(:request_log, response: {
          version: "6",
          timestamp: "2023-07-07T15:32:12.757Z",
          success: true,
          assessment: { client_reference_id: nil,
                        submission_date: "2023-08-03",
                        applicant: {
                          date_of_birth: "1970-01-01",
                        },
                        remarks: {} },
        })
        described_class.call
      end

      it "returns timestamp attribute in response" do
        expect(request_log.response.deep_symbolize_keys).to be_key(:timestamp)
      end

      it "redacts time in timestamp" do
        expect(request_log.response.deep_symbolize_keys[:timestamp]).to eq("2023-07-07")
      end

      it "redacts the applicant DOB" do
        expect(response.dig(:assessment, :applicant, :date_of_birth)).to eq("1969-08-04")
      end
    end

    # Redact response test has already been covered in spec/requests/v6/assessments_controller/simple_spec.rb.
    # RequestLog factory created with sample response remarks just to test the RequestLog remark redaction logic
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
          policy_disregards: %w[
            string
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
