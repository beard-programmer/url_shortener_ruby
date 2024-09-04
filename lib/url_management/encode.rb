# frozen_string_literal: true

require_relative './original_url'
require_relative './infrastructure'
require_relative './encode/request_validated'
require_relative './token_identifier'
require_relative './encode/token'
require_relative './encode/encoded_url'

module UrlManagement
  module Encode
    module_function

    UrlWasEncoded = Data.define(:url, :short_url)

    def call(ticket_service, persist, request:)
      url = request.url
      encode_at_host = request.encode_at_host
      validate_request = RequestValidated.from_unvalidated_request(
        ->(string) { UrlManagement::OriginalUrl.from_string(Infrastructure.method(:parse_url_string), string) },
        url:,
        encode_at_host:
      )
      return validate_request if validate_request.err?

      request = validate_request.unwrap!
      issue_token = UrlManagement::TokenIdentifier.acquire(ticket_service).and_then do |identifier|
        Token.from_token_identifier(
          Infrastructure.codec_base58,
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

      encode_url.map do |encoded_url|
        token = encoded_url.token
        short_url = "https://#{token.token_host}/#{token.token}"
        UrlWasEncoded[encoded_url.url.to_s, short_url]
      end
    end
  end
end
