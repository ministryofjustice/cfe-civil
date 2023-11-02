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
    around do |example|
      Rails.configuration.x.error_handling_enabled = true
      example.run
      Rails.configuration.x.error_handling_enabled = false
    end

    it "returns standard error response" do
      expected_response = {
        success: false,
        errors: ["ZeroDivisionError: divided by 0"],
      }.to_json
      get "/my_test?raise_error=1"
      expect(parsed_response).to eq JSON.parse(expected_response, symbolize_names: true)
    end

    it "is captured by Sentry" do
      expect(Sentry).to receive(:capture_exception).with(instance_of(ZeroDivisionError), extra: {})
      get "/my_test?raise_error=1"
    end
  end
end
