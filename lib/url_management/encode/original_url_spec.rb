# frozen_string_literal: true

# spec/url_management/encode/original_url_spec.rb

require 'rspec'
require_relative './errors'
require_relative '../infrastructure' # for parse_url_string
require_relative './original_url'

RSpec.describe UrlManagement::Encode::OriginalUrl do
  let(:parser) { UrlManagement::Infrastructure }

  describe '.from_string' do
    context 'when the URL is valid' do
      let(:valid_url) { 'https://example.com/path?query=param' }

      it 'returns a Result::Ok containing the OriginalUrl' do
        result = described_class.from_string(parser, valid_url)
        expect(result.ok?).to be(true)
        expect(result.unwrap!).to be_a(described_class)
        expect(result.unwrap!.to_s).to eq(valid_url)
      end
    end

    context 'when the URL has an invalid scheme' do
      let(:invalid_scheme_url) { 'ftp://example.com' }

      it 'returns a Result::Err with a ValidationError' do
        result = described_class.from_string(parser, invalid_scheme_url)
        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(UrlManagement::Encode::ValidationError)
        expect(result.unwrap_err!.message).to eq('Invalid scheme ftp')
      end
    end

    context 'when the URL has a valid scheme but no domain' do
      let(:invalid_domain_url) { 'http://localhost' }

      it 'returns a Result::Err with a ValidationError' do
        result = described_class.from_string(parser, invalid_domain_url)
        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(UrlManagement::Encode::ValidationError)
        expect(result.unwrap_err!.message).to eq('Invalid domain for host localhost')
      end
    end

    context 'when the URL cannot be parsed' do
      let(:unparsable_url) { 'http://invalid url' }

      it 'returns a Result::Err with a ValidationError' do
        allow(parser).to receive(:parse_url_string).and_return(Result.err('ParsingError'))

        result = described_class.from_string(parser, unparsable_url)
        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(UrlManagement::Encode::ValidationError)
        expect(result.unwrap_err!.message).to eq('ParsingError')
      end
    end
  end

  describe 'instance methods' do
    subject(:original_url) { described_class.from_string(parser, valid_url).unwrap! }

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
