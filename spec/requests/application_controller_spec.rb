require "rails_helper"

class TestMockController < ::ApplicationController
  def show
    if params[:raise_error]
      35 / 0
    else
      render_success
    end
  end
end

RSpec.describe ApplicationController, type: :request do
  before do
    Rails.application.routes.draw do
      get "/my_test", to: "test_mock#show"
    end
  end

  after do
    Rails.application.reload_routes!
  end

  context "no error raised" do
    it "returns json success response" do
      expected_response = {
        success: true,
        errors: [],
      }.to_json
      get "/my_test"
      expect(parsed_response).to eq JSON.parse(expected_response, symbolize_names: true)
    end
  end

  context "raising an error", :errors do
    before do
      get "/my_test?raise_error=1"
    end

    it "returns a 500 error" do
      expect(response).to have_http_status(:internal_server_error)
    end

    it "returns standard error response" do
      expected_response = {
        success: false,
        errors: ["ZeroDivisionError: divided by 0"],
      }
      expect(parsed_response).to eq expected_response
    end

    it "is captured by Sentry" do
      expect(Sentry).to receive(:capture_exception).with(instance_of(ZeroDivisionError), extra: {})
      get "/my_test?raise_error=1"
    end
  end
end
