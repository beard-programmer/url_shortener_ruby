# frozen_string_literal: true

require 'rspec'
require_relative './token_host'
require_relative './errors'

RSpec.describe UrlManagement::Encode::TokenHost do
  describe '.from_string' do
    context 'with a valid host' do
      it 'returns a Result::Ok containing the EncodeHost' do
        result = described_class.from_string('short.est')
        expect(result.ok?).to be(true)
        expect(result.unwrap!.host).to eq('short.est')
      end
    end

    context 'with an invalid host' do
      it 'returns a Result::Err containing a ValidationError' do
        result = described_class.from_string('invalid.host')
        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(UrlManagement::Encode::ValidationError)
        expect(result.unwrap_err!.message).to eq('Not allowed to encode url using host invalid.host')
      end
    end
  end
end
