# frozen_string_literal: true

require 'rspec'
require_relative './errors'
require_relative './unclaimed_token'
require_relative './unclaimed_identifier'
require_relative './encoding_host'
require_relative '../infrastructure/codec_base58'

RSpec.describe UrlManagement::Encode::UnclaimedToken do
  describe '.issue' do
    subject(:issue_result) { described_class.issue(codec, unclaimed_identifier, token_host) }

    let(:codec) { UrlManagement::Infrastructure::CodecBase58 }
    let(:unclaimed_identifier) { instance_double(UrlManagement::Encode::UnclaimedIdentifier, value: 58**5) }
    let(:token_host) { UrlManagement::Encode::EncodingHost::EncodingHostDefault.new }

    it 'is ok' do
      expect(issue_result).to be_ok
    end

    it 'is a StandardUnclaimedToken' do
      expect(issue_result.unwrap!).to be_a(UrlManagement::Encode::UnclaimedToken::StandardUnclaimedToken)
    end

    context 'when given unexpected encoding host' do
      let(:token_host) { 123 }

      it 'is err' do
        expect(issue_result).to be_err
      end

      it 'is not implemented' do
        expect(issue_result.unwrap_err!).to be_instance_of(NotImplementedError)
      end
    end
  end

  describe UrlManagement::Encode::UnclaimedToken::StandardUnclaimedToken do
    describe '.issue' do
      subject(:issue_result) { described_class.issue(codec, unclaimed_identifier, token_host) }

      let(:codec) { UrlManagement::Infrastructure::CodecBase58 }
      let(:unclaimed_identifier) { instance_double(UrlManagement::Encode::UnclaimedIdentifier, value: 58**5) }
      let(:token_host) { UrlManagement::Encode::EncodingHost::EncodingHostDefault.new }

      it 'is ok' do
        expect(issue_result).to be_ok
      end

      it 'is standard token' do
        expect(issue_result.unwrap!).to be_a(UrlManagement::Encode::UnclaimedToken::StandardUnclaimedToken)
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
end
