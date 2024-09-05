require_relative '../../../../spec_helper'
require_relative '../../../../../lib/url_management/decode/api/http_response'

RSpec.describe UrlManagement::Decode::Api::HttpResponse do
  describe '.from_decode_result' do
    let(:found_url) { "https://example.com" }
    let(:short_url_host) { 'short.url' }
    let(:short_url_token) { 'qwerty' }
    let(:short_url) { "https://#{short_url_host}/#{short_url_token}" }

    context 'when the result is Ok with DecodedUrlWasFound' do
      let(:result) do
        Result.ok(UrlManagement::Decode::ShortUrlDecoded.new(found_url, short_url_host, short_url_token))
      end

      it 'returns a 200 status with the correct body' do
        response = described_class.from_decode_result(result)
        expect(response.http_status_code).to eq(200)
        expect(response.body).to eq({ url: found_url, short_url: }.to_json)
      end
    end

    context 'when the result is Ok with DecodedUrlWasNotFound' do
      let(:result) { Result.ok(UrlManagement::Decode::OriginalWasNotFound.new(short_url)) }

      it 'returns a 422 status with an error message' do
        response = described_class.from_decode_result(result)
        expect(response.http_status_code).to eq(422)
        expect(response.body).to eq({
          error: {
            code: 'DecodedUrlWasNotFound',
            message: "Not found original url for short: #{short_url}"
          }
        }.to_json)
      end
    end

    context 'when the result is Err with ValidationError' do
      let(:error_message) { "Invalid URL format" }
      let(:result) { Result.err UrlManagement::Decode::ValidationError.new(error_message) }

      it 'returns a 400 status with an error message' do
        response = described_class.from_decode_result(result)
        expect(response.http_status_code).to eq(400)
        expect(response.body).to eq({
          error: {
            code: 'ValidationError',
            message: error_message
          }
        }.to_json)
      end
    end

    context 'when the result is Err with InfrastructureError' do
      let(:error_message) { "Database connection failed" }
      let(:result) { Result.err(UrlManagement::Decode::InfrastructureError.new(error_message)) }

      it 'returns a 500 status with an error message' do
        response = described_class.from_decode_result(result)
        expect(response.http_status_code).to eq(500)
        expect(response.body).to eq({
          error: {
            code: 'InfrastructureError',
            message: error_message
          }
        }.to_json)
      end
    end

    context 'when the result is unexpected' do
      let(:unexpected_result) { "Unexpected result" }

      it 'raises an error' do
        expect do
          described_class.from_decode_result(unexpected_result)
        end.to raise_error('Unexpected decode result')
      end
    end
  end
end
