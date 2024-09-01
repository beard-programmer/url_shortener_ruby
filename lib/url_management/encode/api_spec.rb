# frozen_string_literal: true

require 'rspec'
require 'rack/test'
require_relative '../encode'

RSpec.describe UrlManagement::Encode::Api do
  include Rack::Test::Methods

  def app
    described_class.new
  end

  describe "POST /encode" do
    context "with valid input" do
      let(:valid_json) { { url: "https://example.com" }.to_json }

      it "returns status 200" do
        post '/encode', valid_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eq(200)
      end

      it "returns a short_url in the response" do
        post '/encode', valid_json, { "CONTENT_TYPE" => "applicationr/json" }
        response_data = JSON.parse(last_response.body)
        expect(response_data["short_url"]).to be_a(String)
        expect(response_data["short_url"]).to match(%r{https://short\.est/[1-9A-HJ-NP-Za-km-z]{6}})
      end

      it "returns the original url in the response" do
        post '/encode', valid_json, { "CONTENT_TYPE" => "application/json" }
        response_data = JSON.parse(last_response.body)
        expect(response_data["url"]).to eq("https://example.com")
      end
    end

    context "with invalid input" do
      let(:invalid_json) { { url: "short" }.to_json }

      it "returns status 400" do
        post '/encode', invalid_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eq(400)
      end

      it "returns an error message in the response" do
        post '/encode', invalid_json, { "CONTENT_TYPE" => "application/json" }
        response_data = JSON.parse(last_response.body)
        expect(response_data["error"]).to include("The property '#/url' was not of a minimum string length of 10")
      end
    end

    context "with missing url key" do
      let(:missing_key_json) { {}.to_json }

      it "returns status 400" do
        post '/encode', missing_key_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eq(400)
      end

      it "returns an error message in the response" do
        post '/encode', missing_key_json, { "CONTENT_TYPE" => "application/json" }
        response_data = JSON.parse(last_response.body)

        expect(response_data["error"]).to include("The property '#/' did not contain a required property of 'url'")
      end
    end
  end
end
