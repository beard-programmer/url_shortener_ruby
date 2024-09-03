# frozen_string_literal: true

require_relative '../common/result'
require_relative './infrastructure'
require_relative './original_url'
require_relative './token_identifier'
require_relative './decode/errors'
require_relative './decode/validated_request'
require_relative './decode/token'
require_relative './decode/infrastructure'

module UrlManagement
  module Decode
    extend self

    DecodedUrlWasFound = Data.define(:url, :short_url)
    DecodedUrlWasNotFound = Data.define(:short_url)

    # @param [Sequel::Database] db
    # @param [DecodeRequest] request
    # @return [Result::Ok<DecodedUrlWasNotFound, DecodedUrlWasFound>]
    # @return [Result::Err<ValidationError, InfrastructureError>]
    # @raise [RuntimeError]
    def call(db, request)
      case find_original_url_string(db, request)
      in Result::Ok[encoded_url_string]
        Result.ok DecodedUrlWasFound.new(url: to_original_url.call(encoded_url_string).unwrap!,
                                         short_url: request.short_url)
      in Result::Ok[] then Result.ok DecodedUrlWasNotFound.new(request.short_url)
      in Result::Err[Infrastructure::DatabaseError => e] then Result.err InfrastructureError.new(e)
      in Result::Err[e] then Result.err ValidationError.new(e)
      else raise "Unexpected response when fetching encoded url."
      end
    end

    private

    def find_original_url_string(db, request)
      validate_request = ValidatedRequest.from_unvalidated_request(string_to_uri, request:)
      make_token_identifier = validate_request.and_then do |validated_request|
        decode_string = ->(s) { UrlManagement::Infrastructure::CodecBase58.decode(s) }
        UrlManagement::TokenIdentifier.from_string(decode_string, validated_request.short_url.path[1..])
      end

      make_token_identifier.and_then do |token_identifier|
        Infrastructure.find_encoded_url(db, token_identifier)
      end
    end

    def string_to_uri
      ->(s) { UrlManagement::Infrastructure.parse_url_string(s) }
    end

    def to_original_url
      ->(s) { UrlManagement::OriginalUrl.from_string(string_to_uri, s) }
    end
  end
end
