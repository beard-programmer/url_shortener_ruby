# frozen_string_literal: true

require_relative './result'

module ConstrainedTypes
  class CreateIntegerError < ArgumentError; end

  module_function

  # @param [Integer] value
  # @param [String] type_name
  # @param [Range] size_range
  # @yieldparam value [Integer]
  # @yieldreturn [IntoType]
  # @return [Result::Ok]
  # @return [Result::Err<CreateIntegerError>]
  def create_integer(value, type_name:, size_range:)
    case value
    in Integer if size_range.cover?(value)
      return Result.ok(yield value) if block_given?

      Result.ok value
    in Integer
      Result.err CreateIntegerError.new("#{type_name} must be within #{size_range} range (#{value} given).")
    else
      Result.err CreateIntegerError.new("#{type_name} must be an Integer (#{value} given).")
    end
  end
end
