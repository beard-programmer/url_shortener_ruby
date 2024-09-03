# frozen_string_literal: true

require_relative '../../common/result'
require_relative './token_host'
require_relative './errors'

module UrlManagement
  module Encode
    class ValidatedRequest
      attr_reader :original_url, :token_host

      private_class_method :new

      # @param [#call] parse_original_url
      # @param [String, nil] url
      # @param [String, nil] encode_at_host
      # @return [Result::Ok<self>, Result::Err<ValidationError>]
      # @todo: mb parse into separate?
      def self.from_unvalidated_request(parse_original_url, url:, encode_at_host: nil)
        result = parse_original_url.call(url).and_then do |encode_what|
          encode_where = TokenHost.from_string(encode_at_host).unwrap_or(TokenHostStandard.new)

          case [encode_what.host, encode_where.host]
          in [left, right] if left == right
            Result.err 'Cannot encode self'
          else
            Result.ok new(original_url: encode_what, token_host: encode_where)
          end
        end

        result.map_err { |e| ValidationError.new(e) }
      end

      # @param [UrlManagement::OriginalUrl] original_url
      # @param [#host, #to_s, #domain] token_host
      def initialize(original_url:, token_host:)
        @original_url = original_url
        @token_host = token_host
      end
    end
  end
end
