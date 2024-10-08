# frozen_string_literal: true

require_relative '../../../spec_helper'
require_relative '../../../../lib/url_management/encode/infrastructure'

RSpec.describe UrlManagement::Encode::RequestValidated do
  let(:parse_original_url) do
    lambda { |url|
      UrlManagement::OriginalUrl.from_string(UrlManagement::Encode::Infrastructure.method(:parse_url_string), url)
    }
  end

  describe '.from_unvalidated_request' do
    context 'when the URL is valid and the hosts differ' do
      it 'returns a Result::Ok with a ValidatedRequest' do
        result = described_class.from_unvalidated_request(
          parse_original_url,
          url: 'https://example.com/path',
          encode_at_host: 'short.est'
        )

        expect(result.ok?).to be(true)
        validated_request = result.unwrap!
        expect(validated_request).to be_a(described_class)
        expect(validated_request.original_url.host).to eq('example.com')
        expect(validated_request.token_host.host).to eq('short.est')
      end
    end

    context 'when the URL host and encoding host are the same' do
      it 'returns a Result::Err with a ValidationError' do
        result = described_class.from_unvalidated_request(
          parse_original_url,
          url: 'https://short.est/path',
          encode_at_host: 'short.est'
        )

        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(UrlManagement::Encode::ValidationError)
        expect(result.unwrap_err!.message).to eq('Cannot encode self')
      end
    end

    context 'when the URL cannot be parsed' do
      it 'returns a Result::Err with a ValidationError' do
        result = described_class.from_unvalidated_request(
          parse_original_url,
          url: 'invalid_url',
          encode_at_host: 'short.est'
        )

        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(UrlManagement::Encode::ValidationError)
      end
    end
  end
end
