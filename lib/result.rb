# frozen_string_literal: true

class Result
  class Ok < Result
    def self.[](value)
      new(value)
    end

    # Deconstructs the value for pattern matching.
    #
    # @return [Array]
    def deconstruct
      if value.nil?
        []
      elsif value.is_a?(Array)
        value.to_a
      else
        [value]
      end
    end
  end

  class Err < Result
    def self.[](value)
      new(value)
    end

    # Deconstructs the value for pattern matching.
    #
    # @return [Array]
    def deconstruct
      if value.nil?
        []
      elsif value.is_a?(Array)
        value.to_a
      else
        [value]
      end
    end
  end

  # @!visibility private
  private_class_method :new

  # @!attribute [r] value
  #   @return [Object]
  private attr_reader :value

  # @param value [Object]
  def initialize(value)
    @value = value
  end

  # @return [Boolean]
  def ok?
    is_a?(Ok)
  end

  # @return [Boolean]
  def err?
    is_a?(Err)
  end

  # @return [Object]
  # @raise [RuntimeError]
  def unwrap!
    raise "Called unwrap on an Err value: #{value.inspect}" if err?

    value
  end

  # @param [Object] default
  # @return [Object]
  def unwrap_or(default)
    return default if err?

    value
  end

  # @return [Object]
  # @raise [RuntimeError]
  def unwrap_err!
    raise "Called unwrap_err on an Ok value: #{value.inspect}" if ok?

    value
  end

  # @yield [value]
  # @yieldparam value [Object]
  # @yieldreturn [Object]
  # @return [Result, Result::Ok<Object>]
  def map
    return self if err?

    Result.ok(yield(value))
  end

  # @yield [error]
  # @yieldparam error [Object]
  # @yieldreturn [Object]
  # @return [Result, Result::Err]
  def map_err
    return self if ok?

    Result.err(yield(value))
  end

  # @yield [value]
  # @yieldparam value [Object]
  # @yieldreturn [Result, Result::Ok<Object>, Result::Err<Object>]
  # @return [Result, Result::Ok<Object>, Result::Err<Object>]
  def and_then
    return self if err?

    yield(value)
  end

  # @yield [error]
  # @yieldparam error [Object]
  # @yieldreturn [Result]
  # @return [Result]
  def or_else
    return self if ok?

    yield(value)
  end

  # @param value [Object]
  # @return [Result::Ok]
  def self.ok(value)
    Ok[value]
  end

  # @param [Object] value
  # @return [Result::Err]
  def self.err(value)
    Err[value]
  end
end
