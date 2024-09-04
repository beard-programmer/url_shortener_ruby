# frozen_string_literal: true

require 'addressable'
require_relative '../../common/result'

module UrlManagement
  module Infrastructure
    class ParsingError < StandardError; end

    # @param url_string [String] The URL string to be parsed.
    # @return [Result, Result::Ok<URI>, Result::Err<ParsingError>]
    def self.parse_url_string(url_string)
      return Result.err(ParsingError.new("URL must be string.")) unless url_string.respond_to?(:to_str)
      return Result.err(ParsingError.new("URL too long.")) if 2048 < url_string.length

      parsed = Addressable::URI.parse(url_string)
      return Result.ok(parsed) if parsed

      Result.err(ParsingError.new("Failed to parse URL"))
    rescue NoMethodError, TypeError, ArgumentError, Addressable::URI::InvalidURIError => e
      Result.err(ParsingError.new(e.message))
    end
  end
end
