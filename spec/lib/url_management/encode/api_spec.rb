# # frozen_string_literal: true
#
# require 'rack/test'
# require 'logger'
# require 'sequel'
# require_relative '../../../spec_helper'
# require_relative '../../../../lib/url_management/encode/api'
#
# RSpec.describe UrlManagement::Encode::Api do
#   include Rack::Test::Methods
#
#   def app
#     described_class.set(db:, logger: Logger.new(nil), default_content_type: :json, show_exceptions: false)
#   end
#
#   describe "POST /encode" do
#     let(:db) do
#       # Connect to the test database
#       test_db = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://url_shortener_ruby_test:url_shortener_ruby_test@localhost:5433/url_shortener_ruby_test')
#
#       # Run database migrations
#       Sequel.extension :migration
#       Sequel::Migrator.run(test_db, './lib/db/migrations')
#
#       # Return the database connection
#       test_db
#     end
#
#     before do
#       db[:encoded_urls].truncate(cascade: true)
#     end
#
#     after do
#       Sequel.extension :migration
#       Sequel::Migrator.run(db, "lib/db/migrations", target: 0)
#       db.disconnect
#     end
#
#     context "with valid input" do
#       let(:valid_json) { { url: "https://example.com" }.to_json }
#
#       it "returns status 200" do
#         post '/encode', valid_json, { "CONTENT_TYPE" => "application/json" }
#         expect(last_response.status).to eq(200)
#       end
#
#       it "returns a short_url in the response" do
#         post '/encode', valid_json, { "CONTENT_TYPE" => "applicationr/json" }
#         response_data = JSON.parse(last_response.body)
#         expect(response_data["short_url"]).to be_a(String)
#         expect(response_data["short_url"]).to match(%r{https://short\.est/[1-9A-HJ-NP-Za-km-z]{6}})
#       end
#
#       it "returns the original url in the response" do
#         post '/encode', valid_json, { "CONTENT_TYPE" => "application/json" }
#         response_data = JSON.parse(last_response.body)
#         expect(response_data["url"]).to eq("https://example.com")
#       end
#     end
#
#     context "with invalid input" do
#       let(:invalid_json) { { url: "short" }.to_json }
#
#       it "returns status 400" do
#         post '/encode', invalid_json, { "CONTENT_TYPE" => "application/json" }
#         expect(last_response.status).to eq(400)
#       end
#
#       it "returns an error message in the response" do
#         post '/encode', invalid_json, { "CONTENT_TYPE" => "application/json" }
#         response_data = JSON.parse(last_response.body)
#         expect(response_data["error"]).to include("The property '#/url' was not of a minimum string length of 10")
#       end
#     end
#
#     context "with missing url key" do
#       let(:missing_key_json) { {}.to_json }
#
#       it "returns status 400" do
#         post '/encode', missing_key_json, { "CONTENT_TYPE" => "application/json" }
#         expect(last_response.status).to eq(400)
#       end
#
#       it "returns an error message in the response" do
#         post '/encode', missing_key_json, { "CONTENT_TYPE" => "application/json" }
#         response_data = JSON.parse(last_response.body)
#
#         expect(response_data["error"]).to include("The property '#/' did not contain a required property of 'url'")
#       end
#     end
#   end
# end
