# frozen_string_literal: true

require_relative '../../../spec_helper'
require_relative '../../../../lib/url_management/encode/infrastructure'

RSpec.describe UrlManagement::Encode::TokenStandard do
  describe '.issue' do
    subject(:issue_result) { described_class.from_token_identifier(codec, unclaimed_identifier, token_host) }

    let(:codec) { UrlManagement::Encode::Infrastructure.codec_base58 }
    let(:unclaimed_identifier) { instance_double(UrlManagement::TokenIdentifier, value: 58**5) }
    let(:token_host) { UrlManagement::Encode::TokenHostStandard.new }

    it 'is ok' do
      expect(issue_result).to be_ok
    end

    it 'is standard token' do
      expect(issue_result.unwrap!).to be_a(described_class)
    end

    it 'is an expected value' do
      token = issue_result.unwrap!
      expect([token.token, token.token_key, token.token_host]).to eq(["211111", 58**5, token_host])
    end

    context 'when given unexpected encoding host' do
      let(:token_host) { 123 }

      it 'is raises error' do
        expect { issue_result }.to raise_error(ArgumentError)
      end
    end
  end
end
