# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/url_management/infrastructure'

RSpec.describe UrlManagement::OriginalUrl do
  let(:string_to_uri) { ->(s) { UrlManagement::Infrastructure.parse_url_string(s) } }

  describe '.from_string' do
    context 'when the URL is valid' do
      let(:valid_url) { 'https://example.com/path?query=param' }

      it 'returns a Result::Ok containing the OriginalUrl' do
        result = described_class.from_string(string_to_uri, valid_url)
        expect(result.ok?).to be(true)
        expect(result.unwrap!).to be_a(described_class)
        expect(result.unwrap!.to_s).to eq(valid_url)
      end
    end

    context 'when the URL has an invalid scheme' do
      let(:invalid_scheme_url) { 'ftp://example.com' }

      it 'returns a Result::Err with a ValidationError' do
        result = described_class.from_string(string_to_uri, invalid_scheme_url)
        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_instance_of(StandardError)
        expect(result.unwrap_err!.message).to eq('Invalid scheme ftp')
      end
    end

    context 'when the URL has a valid scheme but no domain' do
      let(:invalid_domain_url) { 'http://localhost' }

      it 'returns a Result::Err with a ValidationError' do
        result = described_class.from_string(string_to_uri, invalid_domain_url)
        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_instance_of(StandardError)
        expect(result.unwrap_err!.message).to eq('Invalid domain for host localhost')
      end
    end

    context 'when the URL cannot be parsed' do
      let(:unparsable_url) { 'http://invalid url' }

      it 'returns a Result::Err with a ValidationError' do
        allow(string_to_uri).to receive(:call).and_return(Result.err('ParsingError'))

        result = described_class.from_string(string_to_uri, unparsable_url)
        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_instance_of(StandardError)
        expect(result.unwrap_err!.message).to eq('ParsingError')
      end
    end
  end

  describe 'instance methods' do
    subject(:original_url) { described_class.from_string(string_to_uri, valid_url).unwrap! }

    describe '#host' do
      let(:valid_url) { 'https://example.com/path?query=param' }

      it 'returns the host of the URI' do
        expect(original_url.host).to eq('example.com')
      end
    end

    describe '#domain' do
      let(:valid_url) { 'https://sub.example.com/path?query=param' }

      it 'returns the domain of the URI' do
        expect(original_url.domain).to eq('example.com')
      end
    end

    describe '#to_s' do
      let(:valid_url) { 'https://example.com/path?query=param' }

      it 'returns the original URL string' do
        expect(original_url.to_s).to eq(valid_url)
      end
    end
  end
end
