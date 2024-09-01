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
        create_integer(value, type_name: 'IntegerBase58Exp5To6', size_range: (MIN_VALID..MAX_VALID)) { |i| new(i) }
      end

      # @param [Integer] value
      def initialize(value)
        @value = value
      end
    end

    class StringBase58Exp5To6
      extend ConstrainedTypes

      private_class_method :new
      attr_reader :value

      def self.from_string(value)
        pattern = /^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$/
        create_string(
          value, type_name: 'StringBase58Exp5To6', length_range: (6...7), pattern:
        ) { |s| new(s) }
      end

      def initialize(value)
        @value = value
      end
    end
  end
end
