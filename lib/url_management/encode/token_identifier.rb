# frozen_string_literal: true

require_relative '../../common/result'
require_relative '../simple_types'
require_relative './errors'

module UrlManagement
  module Encode
    class TokenIdentifier
      private_class_method :new

      # @ return [Integer]
      attr_reader :value

      # @param [#call] ticket_service - Result::Ok<Integer> | Result::Err<>
      # @return [Result::Ok<self>, Result::Err<InfrastructureError>, Result::Err<ApplicationError>]
      def self.acquire(ticket_service)
        result = ticket_service.call
        return result.map_err { |e| InfrastructureError.new(e) } if result.err?

        integer = result.unwrap!

        result = SimpleTypes::IntegerBase58Exp5To6.from_integer(integer)
        return result.map_err { |e| ApplicationError.new(e) } if result.err?

        Result.ok new(result.unwrap!.value)
      end

      def initialize(value)
        @value = value
      end
    end
  end
end
