# frozen_string_literal: true

require_relative '../spec/spec_helper'
require_relative './result'

RSpec.describe Result do
  describe '.ok' do
    it 'creates an Ok object' do
      result = described_class.ok(42)
      expect(result).to be_a(Result::Ok)
      expect(result.ok?).to be true
      expect(result.err?).to be false
    end
  end

  describe '.err' do
    it 'creates an Err object' do
      result = described_class.err('error')
      expect(result).to be_a(Result::Err)
      expect(result.ok?).to be false
      expect(result.err?).to be true
    end
  end

  describe '#unwrap!' do
    context 'when the result is Ok' do
      it 'returns the value' do
        result = described_class.ok(42)
        expect(result.unwrap!).to eq(42)
      end
    end

    context 'when the result is Err' do
      it 'raises an error' do
        result = described_class.err('error')
        expect { result.unwrap! }.to raise_error(RuntimeError, 'Called unwrap on an Err value: "error"')
      end
    end
  end

  describe '#unwrap_err!' do
    context 'when the result is Ok' do
      it 'raises an error' do
        result = described_class.ok(42)
        expect { result.unwrap_err! }.to raise_error(RuntimeError, 'Called unwrap_err on an Ok value: 42')
      end
    end

    context 'when the result is Err' do
      it 'returns the error' do
        result = described_class.err('error')
        expect(result.unwrap_err!).to eq('error')
      end
    end
  end

  describe '#map' do
    context 'when the result is Ok' do
      it 'applies the block to the value and returns a new Ok result' do
        result = described_class.ok(42).map { |value| value + 1 }
        expect(result.unwrap!).to eq(43)
        expect(result).to be_a(Result::Ok)
      end
    end

    context 'when the result is Err' do
      it 'returns itself without applying the block' do
        result = described_class.err('error').map { |value| value + 1 }
        expect(result.unwrap_err!).to eq('error')
        expect(result).to be_a(Result::Err)
      end
    end
  end

  describe '#map_err' do
    context 'when the result is Ok' do
      it 'returns itself without applying the block' do
        result = described_class.ok(42).map_err { |error| error.upcase }
        expect(result.unwrap!).to eq(42)
        expect(result).to be_a(Result::Ok)
      end
    end

    context 'when the result is Err' do
      it 'applies the block to the error and returns a new Err result' do
        result = described_class.err('error').map_err { |error| error.upcase }
        expect(result.unwrap_err!).to eq('ERROR')
        expect(result).to be_a(Result::Err)
      end
    end
  end

  describe '#and_then' do
    context 'when the result is Ok' do
      it 'chains another operation on the value and returns a new Ok result' do
        result = described_class.ok(42).and_then { |value| described_class.ok(value + 1) }
        expect(result.unwrap!).to eq(43)
        expect(result).to be_a(Result::Ok)
      end
    end

    context 'when the result is Err' do
      it 'returns itself without chaining another operation' do
        result = described_class.err('error').and_then { |value| described_class.ok(value + 1) }
        expect(result.unwrap_err!).to eq('error')
        expect(result).to be_a(Result::Err)
      end
    end
  end

  describe '#or_else' do
    context 'when the result is Ok' do
      it 'returns itself without chaining another operation' do
        result = described_class.ok(42).or_else { |error| described_class.err(error.upcase) }
        expect(result.unwrap!).to eq(42)
        expect(result).to be_a(Result::Ok)
      end
    end

    context 'when the result is Err' do
      it 'chains another operation on the error and returns a new Err result' do
        result = described_class.err('error').or_else { |error| described_class.err(error.upcase) }
        expect(result.unwrap_err!).to eq('ERROR')
        expect(result).to be_a(Result::Err)
      end
    end
  end
end
