# frozen_string_literal: true

require 'rspec'
require_relative './encoding_token_unclaimed'
require_relative './errors'

RSpec.describe UrlManagement::Encode::EncodingTokenUnclaimed do
  describe '.issue' do
    context 'when token_producer succeeds and produces a valid integer' do
      let(:valid_integer) { 58**5 }
      let(:token_producer) { -> { Result.ok(valid_integer) } }

      it 'returns a Result::Ok with an EncodeTokenUnclaimed' do
        result = described_class.issue(token_producer)

        expect(result.ok?).to be(true)
        expect(result.unwrap!).to be_a(described_class)
        expect(result.unwrap!.value).to be_a(UrlManagement::SimpleTypes::IntegerBase58Exp5To6)
        expect(result.unwrap!.value.value).to eq(58**5)
      end
    end

    context 'when token_producer fails' do
      let(:token_producer) { -> { Result.err('Some infrastructure error') } }

      it 'returns a Result::Err with an InfrastructureError' do
        result = described_class.issue(token_producer)

        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(UrlManagement::Encode::InfrastructureError)
        expect(result.unwrap_err!.message).to eq('Some infrastructure error')
      end
    end

    [nil, 15.5, "wtf"].each do |not_integer|
      context 'when produced not an integer' do
        let(:token_producer) { -> { Result.ok(not_integer) } }

        it 'returns a Result::Err with an ApplicationError' do
          result = described_class.issue(token_producer)

          expect(result.err?).to be(true)
          expect(result.unwrap_err!).to be_a(UrlManagement::Encode::ApplicationError)
          expect(result.unwrap_err!.message).to include("IntegerBase58Exp5To6 must be an Integer")
        end
      end
    end

    [-100, 0, 58**6].each do |invalid_integer|
      context 'when the integer produced is invalid according to IntegerBase58Exp5To6' do
        let(:token_producer) { -> { Result.ok(invalid_integer) } }

        it 'returns a Result::Err with an ApplicationError' do
          result = described_class.issue(token_producer)

          expect(result.err?).to be(true)
          expect(result.unwrap_err!).to be_a(UrlManagement::Encode::ApplicationError)
          expect(result.unwrap_err!.message).to include("IntegerBase58Exp5To6 must be within 656356768..38068692543 range")
        end
      end
    end
  end
end
