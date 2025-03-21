require "rails_helper"

RSpec.describe StatusController, type: :request do
  describe "#healthcheck" do
    context "when an infrastructure problem exists" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:database_exists?).and_raise(PG::ConnectionBad, "error")

        get "/healthcheck"
      end

      let(:failed_healthcheck) do
        {
          "checks" => {
            "database" => false,
          },
        }.to_json
      end

      it "returns status bad gateway" do
        expect(response).to have_http_status :bad_gateway
      end

      it "returns the expected response report" do
        expect(response.body).to eq(failed_healthcheck)
      end
    end

    context "when everything is ok" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:database_exists?).and_return(true)
        create(:request_log)

        get "/healthcheck"
      end

      let(:expected_response) do
        {
          "checks" => {
            "database" => true,
          },
        }.to_json
      end

      it "returns HTTP success" do
        get "/healthcheck"
        expect(response.status).to eq(200)
      end

      it "returns the expected response report" do
        get "/healthcheck"
        expect(response.body).to eq(expected_response)
      end
    end
  end

  describe "#ping" do
    context "when environment variables set" do
      let(:expected_json) do
        {
          "build_date" => "20150721",
          "build_tag" => "test",
          "app_branch" => "test_branch",
        }
      end

      before do
        allow(Rails.configuration.x.status).to receive_messages(build_date: "20150721", build_tag: "test", app_branch: "test_branch")

        get("/ping")
      end

      it "returns JSON with app information" do
        expect(JSON.parse(response.body)).to eq(expected_json)
      end
    end

    context "when environment variables not set" do
      before do
        allow(Rails.configuration.x.status).to receive_messages(build_date: "Not Available", build_tag: "Not Available", app_branch: "Not Available")

        get "/ping"
      end

      it 'returns "Not Available"' do
        expect(JSON.parse(response.body).values).to be_all("Not Available")
      end
    end
  end
end
