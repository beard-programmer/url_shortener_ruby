# frozen_string_literal: true

require_relative '../simple_types'

module UrlManagement
  module Encode
    class EncodingTokenUnclaimed
      MIN_VALID = 58.pow(5)
      MAX_VALID = 58.pow(6) - 1

      private_class_method :new

      # @ return [SimpleTypes::IntegerBase58Exp5To6]
      attr_reader :value

      # @param [#call] token_producer - Result::Ok<Integer> | Result::Err<>
      # @return [Result::Ok<self>, Result::Err<InfrastructureError>, Result::Err<ApplicationError>]
      def self.issue(token_producer)
        result = token_producer.call
        return result.map_err { |e| InfrastructureError.new(e) } if result.err?

        integer = result.unwrap!

        result = SimpleTypes::IntegerBase58Exp5To6.from_integer(integer)
        return result.map_err { |e| ApplicationError.new(e) } if result.err?

        Result.ok new(result.unwrap!)
      end

      def initialize(value)
        @value = value
      end
    end
  end
end
