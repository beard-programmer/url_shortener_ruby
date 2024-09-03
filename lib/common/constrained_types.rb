# frozen_string_literal: true

require_relative './result'

module ConstrainedTypes
  class CreateIntegerError < ArgumentError; end
  class CreateStringError < ArgumentError; end

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

  # @yieldparam value [String]
  # @yieldreturn [IntoType]
  # @return [Result::Ok]
  # @return [Result::Err<CreateStringError>]
  def create_string(value, type_name:, length_range: nil, pattern: nil, inclusion: nil, exclusion: nil)
    case [value, length_range, pattern, inclusion, exclusion]
    in [String, Range => range, *] if !range.cover?(value.size)
      Result.err CreateStringError.new("#{type_name} must be within #{length_range} chars (#{value} given).")
    in [String, _, Regexp, *] if !value.match?(pattern)
      Result.err CreateStringError.new("#{type_name} must be match pattern #{pattern} (#{value} given).")
    in [String, _, _, Array => include, *] if !include.include? value
      Result.err CreateStringError.new("#{type_name} must be included in #{include} (#{value} given).")
    in [String, _, _, _, Array => exclude] if exclude.include? value
      Result.err CreateStringError.new("#{type_name} must be not included in #{exclude} (#{value} given).")
    in [String, *]
      return Result.ok(yield value) if block_given?

      Result.ok value
    else Result.err CreateStringError.new("#{type_name} must be a string (#{value} given)")
    end
  end
end
