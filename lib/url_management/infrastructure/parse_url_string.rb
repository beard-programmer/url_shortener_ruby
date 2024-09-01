# frozen_string_literal: true

module UrlManagement
  module Infrastructure
    require 'addressable'

    class ParsingError < StandardError; end

    # @param url_string [String] The URL string to be parsed.
    # @return [Result, Result::Ok<URI>, Result::Err<ParsingError>]
    def self.parse_url_string(url_string)
      raise ArgumentError, "Too long." if 2048 < url_string.size

      parsed = Addressable::URI.parse(url_string)
      if parsed
        Result.ok parsed
      else
        Result.err ParsingError.new
      end
    rescue NoMethodError, TypeError, ArgumentError, Addressable::URI::InvalidURIError => e
      Result.err ParsingError.new(e.detailed_message)
    end
  end
end
