# frozen_string_literal: true

module UrlManagement
  module Encode
    class ValidatedRequest
      attr_reader :encode_what, :encode_where

      private_class_method :new

      # @param [#call] parse_original_url
      # @param [String, nil] url
      # @param [String, nil] encode_at_host
      # @return [Result::Ok<self>, Result::Err<ValidationError>]
      def self.from_unvalidated_request(parse_original_url, url:, encode_at_host: nil)
        result = parse_original_url.call(url).and_then do |encode_what|
          encode_where = EncodeOnHost.from_string(encode_at_host).unwrap_or(EncodeOnHost.default)

          case [encode_what.host, encode_where.host]
          in [left, right] if left == right
            Result.err 'Cannot encode self'
          else
            Result.ok new(encode_what:, encode_where:)
          end
        end

        result.map_err { |e| ValidationError.new(e) }
      end

      # @param [OriginalUrl] encode_what
      # @param [EncodeOnHost] encode_where
      def initialize(encode_what:, encode_where:)
        @encode_what = encode_what
        @encode_where = encode_where
      end
    end
  end
end

#     # .....
#     # ValidatedRequest(original_url, host)
#     # issue token (from db only)
#     # we have token, validated_url, validated_token_host
#     # apply token (produce key) token++host = key(string, host)
#     # associate url with key #background
#     #
#   end
# end
