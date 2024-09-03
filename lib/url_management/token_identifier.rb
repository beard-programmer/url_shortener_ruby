# frozen_string_literal: true

require_relative '../common/result'
require_relative './simple_types'

module UrlManagement
  class TokenIdentifier
    private_class_method :new

    # @ return [Integer]
    attr_reader :value

    # @param [#call] ticket_service - Result::Ok<Integer> | Result::Err<>
    # @return [Result::Ok<self>, Result::Err<InfrastructureError>, Result::Err<ApplicationError>]
    def self.acquire(ticket_service)
      ticket = ticket_service.call

      base58integer = ticket.and_then do |value|
        SimpleTypes::IntegerBase58Exp5To6.from_integer(value)
      end

      base58integer.map do |integer|
        new(integer.value)
      end
    end

    def initialize(value)
      @value = value
    end
  end
end
