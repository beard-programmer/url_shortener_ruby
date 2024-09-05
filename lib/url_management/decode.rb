# frozen_string_literal: true

require_relative '../common/result'
require_relative './original_url'
require_relative './token_identifier'
require_relative './decode/errors'
require_relative './decode/request_validated'
require_relative './decode/infrastructure'

module UrlManagement
  module Decode
    OriginalFoundInCache = Data.define(:url, :short_url_host, :short_url_token)
    ShortUrlDecoded = Data.define(:url, :short_url_host, :short_url_token)
    OriginalWasNotFound = Data.define(:short_url)

    # @param [Sequel::Database] db
    # @param [Request] request
    # @return [Result::Ok<DecodedUrlWasNotFound, ShortUrlDecoded>]
    # @return [Result::Err<ValidationError, InfrastructureError>]
    # @raise [RuntimeError]
    def self.call(db, request:)
      validate_request = RequestValidated.from_unvalidated_request(Infrastructure.method(:parse_url_string), request:)

      to_token_identifier = validate_request.and_then do |validated_request|
        UrlManagement::TokenIdentifier.from_string(Infrastructure.codec_base58.method(:decode),
                                                   validated_request.short_url.token)
      end

      find_encoded_url = to_token_identifier.and_then do |token_identifier|
        Infrastructure.find_encoded_url(db, token_identifier)
      end
      case find_encoded_url
      in Result::Ok[encoded_url_string]
        url = UrlManagement::OriginalUrl.from_string(Infrastructure.method(:parse_url_string),
                                                     encoded_url_string).unwrap!.to_s
        short_url = validate_request.unwrap!.short_url
        Result.ok ShortUrlDecoded.new(url:, short_url_host: short_url.host, short_url_token: short_url.token)
      in Result::Ok[] then Result.ok OriginalWasNotFound.new(request.short_url)
      in Result::Err[Infrastructure::DatabaseError => e] then Result.err InfrastructureError.new(e)
      in Result::Err[e] then Result.err ValidationError.new(e)
      else raise "Unexpected response when fetching encoded url."
      end
    end
  end
end
