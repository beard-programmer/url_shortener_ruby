# frozen_string_literal: true

require_relative './original_url'
require_relative './infrastructure'
require_relative './encode/validated_request'
require_relative './encode/token_identifier'
require_relative './encode/token'
require_relative './encode/encoded_url'

module UrlManagement
  module Encode
    module_function

    def call(ticket_service, persist, url:, encode_at_host: nil)
      string_to_url = ->(s) { UrlManagement::Infrastructure.parse_url_string(s) }
      validate_request = ValidatedRequest.from_unvalidated_request(
        ->(string) { UrlManagement::OriginalUrl.from_string(string_to_url, string) },
        url:,
        encode_at_host:
      )
      return validate_request if validate_request.err?

      request = validate_request.unwrap!
      issue_token = TokenIdentifier.acquire(ticket_service).and_then do |identifier|
        Token.from_token_identifier(
          UrlManagement::Infrastructure::CodecBase58,
          identifier,
          request.token_host
        )
      end

      encode_url = issue_token.and_then do |token|
        EncodedUrl.to_encoded_url(url: request.original_url, token:)
      end

      save_encoded_url = encode_url.and_then do |encoded_url|
        persist.call(encoded_url)
      end

      return save_encoded_url if save_encoded_url.err?

      encode_url
    end
  end
end
