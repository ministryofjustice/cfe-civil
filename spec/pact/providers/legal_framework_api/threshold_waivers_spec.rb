require "rails_helper"

RSpec.describe "Threshold waivers by proceeding contract", :pact do
  include_context "with legal framework api consumer pact"

  describe LegalFrameworkAPI::ThresholdWaivers do
    let(:interaction) do
      new_interaction
        .given("threshold waivers exist")
        .upon_receiving("a request for threshold waivers by proceeding type")
        .with_request(
          method: :post,
          path: "/threshold_waivers",
          headers: {
            "Content-Type" => "application/json",
          },
          body: {
            request_id: match_regex(UUID_REGEX, "ff9679d7-ca3e-40b8-a47e-5006895d9026"),
            proceedings: [
              {
                ccms_code: "DA005",
                client_involvement_type: "A",
              },
            ],
          },
        )
        .will_respond_with(
          status: 200,
          headers: {
            "Content-Type" => "application/json",
          },
          body: expected_stubbed_body,
        )
    end

    # see https://github.com/pact-foundation/pact-ruby#matchers
    let(:expected_stubbed_body) do
      {
        proceedings: match_each(
          {
            ccms_code: match_regex(/^[A-Z0-9]+$/, "DA005"),
            sca_core: match_any_boolean(false),
            sca_related: match_any_boolean(false),
            client_involvement_type: match_regex(/^[ADWIZ]$/, "A"),
            gross_income_upper: match_any_boolean(true),
            disposable_income_upper: match_any_boolean(true),
            capital_upper: match_any_boolean(true),
            matter_type: match_any_string("domestic abuse (DA)"),
          },
        ),
      }
    end

    it "executes the pact test without errors" do
      interaction.execute do |mock_server|
        allow(Rails.configuration.x).to receive(:legal_framework_api_host).and_return(mock_server.url)

        client = described_class.new(
          [
            {
              ccms_code: "DA005",
              client_involvement_type: "A",
            },
          ],
        )

        result = client.call

        expect(result).not_to be_empty
      end
    end
  end
end
