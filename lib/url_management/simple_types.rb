# frozen_string_literal: true

require_relative '../result'
require_relative '../constrained_types'

module UrlManagement
  module SimpleTypes
    class IntegerBase58Exp5To6
      extend ConstrainedTypes

      MIN_VALID = 58.pow(5)
      MAX_VALID = 58.pow(6) - 1

      private_class_method :new

      attr_reader :value

      # @param [Integer] value
      # @return [Result::Ok<IntegerBase58Exp5To6>, Result::Err<CreateIntegerError>]
      def self.from_integer(value)
        create_integer(value, type_name: 'IntegerBase58Exp5To6', size_range: (MIN_VALID..MAX_VALID)) { |v| new(v) }
      end

      # @param [Integer] value
      def initialize(value)
        @value = value
      end
    end
  end
end
