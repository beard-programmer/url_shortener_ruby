# frozen_string_literal: true

require 'rspec'
require_relative './unclaimed_identifier'
require_relative './errors'

RSpec.describe UrlManagement::Encode::UnclaimedIdentifier do
  describe '.acquire' do
    subject { described_class.acquire(ticket_service) }

    context 'when token_producer succeeds and produces a valid integer' do
      let(:valid_integer) { 58**5 }
      let(:ticket_service) { -> { Result.ok(valid_integer) } }

      it 'returns a Result::Ok with an UnclaimedIdentifier' do
        result = subject

        expect(result.ok?).to be(true)
        expect(result.unwrap!).to be_a(described_class)
        expect(result.unwrap!.value).to eq(58**5)
      end
    end

    context 'when ticket_service fails' do
      let(:ticket_service) { -> { Result.err('Some infrastructure error') } }

      it 'returns a Result::Err with an InfrastructureError' do
        result = subject

        expect(result.err?).to be(true)
        expect(result.unwrap_err!).to be_a(UrlManagement::Encode::InfrastructureError)
        expect(result.unwrap_err!.message).to eq('Some infrastructure error')
      end
    end

    [nil, 15.5, "wtf"].each do |not_integer|
      context 'when ticket service returned not an integer' do
        let(:ticket_service) { -> { Result.ok(not_integer) } }

        it 'returns a Result::Err with an ApplicationError' do
          result = subject

          expect(result.err?).to be(true)
          expect(result.unwrap_err!).to be_a(UrlManagement::Encode::ApplicationError)
          expect(result.unwrap_err!.message).to include("IntegerBase58Exp5To6 must be an Integer")
        end
      end
    end

    [-100, 0, 58**6].each do |invalid_integer|
      context 'when ticket service gave integer that is invalid according to IntegerBase58Exp5To6' do
        let(:ticket_service) { -> { Result.ok(invalid_integer) } }

        it 'returns a Result::Err with an ApplicationError' do
          result = subject

          expect(result.err?).to be(true)
          expect(result.unwrap_err!).to be_a(UrlManagement::Encode::ApplicationError)
          expect(result.unwrap_err!.message).to include("IntegerBase58Exp5To6 must be within 656356768..38068692543 range")
        end
      end
    end
  end
end
