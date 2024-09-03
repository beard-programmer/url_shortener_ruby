# frozen_string_literal: true

require_relative '../common/result'
require_relative './simple_types'

module UrlManagement
  class TokenIdentifier
    private_class_method :new

    # @ return [Integer]
    attr_reader :value

    # @param [#call] ticket_service - Result::Ok<Integer> | Result::Err<>
    # @return [Result::Ok<self>, Result::Err]
    def self.acquire(ticket_service)
      ticket_service.call.and_then do |integer|
        from_integer(integer)
      end
    end

    # @param [#call] decode_token_key
    # @param [String] string
    # @return [Result::Ok<self>, Result::Err]
    def self.from_string(decode_token_key, string)
      decoded_token = SimpleTypes::StringBase58Exp5To6.from_string(string).and_then do |key|
        decode_token_key.call(key.value)
      end

      decoded_token.and_then do |integer|
        from_integer(integer)
      end
    end

    # @param [Integer] value
    # @return [Result::Ok<self>, Result::Err]
    # @!visibility private
    private_class_method def self.from_integer(value)
      SimpleTypes::IntegerBase58Exp5To6.from_integer(value).map do |integer|
        new(integer.value)
      end
    end

    def initialize(value)
      @value = value
    end
  end
end
