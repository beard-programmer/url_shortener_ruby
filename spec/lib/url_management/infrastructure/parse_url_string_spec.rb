# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe UrlManagement::Infrastructure do
  describe '.parse_url_string' do
    context 'when the URL string is valid' do
      it 'returns a Result::Ok with the parsed URI' do
        url = 'https://example.com/path?query=param'
        result = described_class.parse_url_string(url)

        expect(result.ok?).to be(true)
        expect(result.unwrap!).to be_a(Addressable::URI)
        expect(result.unwrap!.to_s).to eq(url)
      end
    end

    context 'when the URL string is too long' do
      it 'raises an ArgumentError and returns Result::Err with ParsingError' do
        long_url = 'https://example.com/' + 'a' * 2049
        result = described_class.parse_url_string(long_url)
        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(described_class::ParsingError)
      end
    end

    context 'when the URL string is invalid' do
      it 'returns a Result::Err with a ParsingError' do
        invalid_url = 'https://example .com'

        result = described_class.parse_url_string(invalid_url)

        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(described_class::ParsingError)
      end
    end

    context 'when the URL string is nil' do
      it 'returns a Result::Err with a ParsingError' do
        result = described_class.parse_url_string(nil)

        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(described_class::ParsingError)
      end
    end
  end
end
