# # frozen_string_literal: true
#
require 'logger'
require 'sequel'
require_relative '../../../spec_helper'
require_relative '../../../../lib/url_management/decode/api'

RSpec.describe UrlManagement::Decode::Api do
  describe '.handle_http' do
    subject(:api_response) { described_class.handle_http(db:, logger: Logger.new(nil), body:) }

    let(:db) do
      # Connect to the test database
      test_db = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://url_shortener_ruby_test:url_shortener_ruby_test@localhost:5433/url_shortener_ruby_test')

      # Run database migrations
      Sequel.extension :migration
      Sequel::Migrator.run(test_db, './lib/db/migrations')

      # Return the database connection
      test_db
    end

    before do
      db[:encoded_urls].truncate(cascade: true)
    end

    after do
      db.disconnect
    end

    [
      '/.213*U@!~IJLKM?SD>',
      123,
      nil,
      { shortEN_url: "https://short.est/21112C" }.to_json,
      { short_url: "ftp://short.est/21112C" }.to_json,
      { short_url: "https_\\short.est/21112C" }.to_json,
      { short_url: "http://short.est/211" }.to_json,
      { short_url: "https://short.est/211" }.to_json,
      { short_url: "https://short.est/211ML~!IJLK>>?ZX_" }.to_json,
      { short_url: "https://short.est/111111" }.to_json,
      { short_url: "https://short.est/2111111" }.to_json

    ].each do |not_valid_body|
      context 'given not valid body' do
        let(:body) { not_valid_body }

        it 'is http response' do
          expect(api_response).to be_instance_of(described_class::HttpResponse)
        end

        it 'is 400' do
          expect(api_response.http_status_code).to eq(400)
        end

        it 'is ValidationError' do
          expect(api_response.body).to include('ValidationError')
        end
      end
    end

    [
      {
        body: { short_url: "https://short.est/21112C" },
        original_url: 'https://sinatrarb.com/extensions.html',
        token_identity: 656_356_837
      },
      {
        body: { short_url: "http://short.est/21112C" },
        original_url: 'http://sinatrarb.com/extensions.html',
        token_identity: 656_356_837
      },
      {
        body: { short_url: "https://short.est/zzzzzz" },
        original_url: 'https://sinatrarb.com/extensions.html',
        token_identity: 38_068_692_543
      },
      {
        body: { short_url: "https://short.est/zzzzzz" },
        original_url: 'https://github.com/sinatra/sinatra-recipes/blob/main/middleware/rack_parser.md',
        token_identity: 38_068_692_543
      },
      {
        body: { short_url: "http://short.est/zzzzzz" },
        original_url: 'https://github.com/sinatra/sinatra-recipes/blob/main/middleware/rack_parser.md',
        token_identity: 38_068_692_543
      }

    ].each do |example|
      context 'given valid body' do
        let(:body) { example[:body].to_json }

        it 'is http response' do
          expect(api_response).to be_instance_of(described_class::HttpResponse)
        end

        context 'and when original url is not present in db' do
          it 'is 422' do
            expect(api_response.http_status_code).to eq(422)
          end

          it 'is ValidationError' do
            expect(api_response.body).to include('DecodedUrlWasNotFound')
          end
        end

        context 'and when it is present in db' do
          before do
            db[:encoded_urls].insert(token_identifier: example[:token_identity], url: example[:original_url])
          end

          it 'is 200' do
            expect(api_response.http_status_code).to eq(200)
          end

          it 'is correct short + original' do
            expect(api_response.body).to eq({ url: example[:original_url],
                                              short_url: example[:body][:short_url] }.to_json)
          end
        end
      end
    end

    [
      {
        body: { short_url: "https://short.est/21112C" },
        token_identifier: 656_356_837,
        invalid_original_url: 'FTP://github.com/sinatra/sinatra-recipes/blob/main/middleware/rack_parser.md'
      }
    ].each do |example|
      context 'when crippled data sneaked into db' do
        before do
          db[:encoded_urls].insert(token_identifier: example[:token_identifier], url: example[:invalid_original_url])
        end

        let(:body) { example[:body].to_json }

        it 'raises runtime error' do
          expect { api_response }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
