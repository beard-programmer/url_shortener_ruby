# spec/url_management/api_schema_middleware_spec.rb
require 'rack/mock'
require 'json-schema'
require_relative '../../lib/url_management/api_schema_middleware'

RSpec.describe UrlManagement::ApiSchemaMiddleware do
  let(:app) { ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['OK']] } }
  let(:schema) do
    {
      "type": "object",
      "properties": {
        "url": {
          "type": "string",
          "minLength": 10
        }
      },
      "required": ["url"]
    }
  end

  let(:middleware) { described_class.new(app, schema) }
  let(:request) { Rack::MockRequest.new(middleware) }

  context "when the request body is valid" do
    let(:valid_body) { { url: "https://example.com" }.to_json }

    it "calls the next app in the stack" do
      response = request.post('/', input: valid_body, 'CONTENT_TYPE' => 'application/json')
      expect(response.status).to eq(200)
      expect(response.body).to eq('OK')
    end
  end

  context "when the request body is invalid" do
    let(:invalid_body) { { url: "short" }.to_json }

    it "returns a 400 status with a validation error message" do
      response = request.post('/', input: invalid_body, 'CONTENT_TYPE' => 'application/json')
      expect(response.status).to eq(400)
      expect(response.body).to include("was not of a minimum string length of 10")
    end
  end

  context "when the request body is missing the required field" do
    let(:missing_field_body) { {}.to_json }

    it "returns a 400 status with a validation error message" do
      response = request.post('/', input: missing_field_body, 'CONTENT_TYPE' => 'application/json')
      expect(response.status).to eq(400)
      expect(response.body).to include("did not contain a required property of 'url'")
    end
  end

  context "when the request body is not valid JSON" do
    let(:invalid_json) { "not a valid json" }

    it "returns a 400 status with a JSON parser error message" do
      response = request.post('/', input: invalid_json, 'CONTENT_TYPE' => 'application/json')
      expect(response.status).to eq(400)
      expect(response.body).to include("The property '#/' of type string did not match the following type: object")
    end
  end

  context "when middleware is given invalid schema" do
    let(:app) { ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['OK']] } }
    let(:invalid_schema) do
      {
        "type": "obkect", # intentional typo
        "properties": {
          "url": {
            "type": "string",
            "minLength": 10
          }
        },
        "required": ["url"]
      }
    end

    let(:middleware) { described_class.new(app, invalid_schema) }
    let(:request) { Rack::MockRequest.new(middleware) }

    it "raises a JSON::Schema::SchemaError or returns a 500 error" do
      expect do
        request.post('/', input: { url: "https://example.com" }.to_json, 'CONTENT_TYPE' => 'application/json')
      end.to raise_error(JSON::Schema::ValidationError)
    end
  end
end
