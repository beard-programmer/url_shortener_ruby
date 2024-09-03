# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe UrlManagement::Encode::Token do
  describe '.issue' do
    subject(:issue_result) { described_class.issue(codec, unclaimed_identifier, token_host) }

    let(:codec) { UrlManagement::Infrastructure::CodecBase58 }
    let(:unclaimed_identifier) { instance_double(UrlManagement::Encode::TokenIdentifier, value: 58**5) }
    let(:token_host) { UrlManagement::Encode::TokenHostStandard.new }

    it 'is ok' do
      expect(issue_result).to be_ok
    end

    it 'is a StandardUnclaimedToken' do
      expect(issue_result.unwrap!).to be_a(UrlManagement::Encode::TokenStandard)
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
end
