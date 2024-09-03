# frozen_string_literal: true

require_relative '../common/result'
require_relative './infrastructure'
require_relative './decode/errors'
require_relative './decode/validated_request'
require_relative './decode/token'
require_relative './decode/fetch_encoded_url'
require_relative './original_url'

module UrlManagement
  module Decode
    extend self

    DecodedUrlWasFound = Data.define(:url, :short_url)
    DecodedUrlWasNotFound = Data.define(:short_url)

    # @param [Sequel::Database] db
    # @param [DecodeRequest] request
    # @return [Result::Ok<DecodedUrlWasNotFound, DecodedUrlWasFound>]
    # @return [Result::Err<ValidationError, InfrastructureError>]
    def call(db, request)
      short_url = request.short_url
      case build_token_identity(short_url)
      in Result::Err[e] then Result.err ValidationError.new(e)
      in Result::Ok[token_identity]
        case FetchEncodedUrl.by_token_identifier(db, token_identity)
        in Result::Ok[value]
          # If for some reason original URL from datasource is invalid - either code is broken or data is not trusted.
          # It is exceptional and unexpected so we fail in runtime.
          url = to_original_url.call(value).unwrap!.to_s
          Result.ok DecodedUrlWasFound.new(url:, short_url:)
        in Result::Ok[] then Result.ok DecodedUrlWasNotFound.new(short_url)
        in Result::Err[e] then Result.err InfrastructureError.new(e)
        else raise "Unexpected response when fetching encoded url."
        end
      else raise "Unexpected response when building token identity from #{short_url}"
      end
    end

    private

    def string_to_uri
      ->(s) { UrlManagement::Infrastructure.parse_url_string(s) }
    end

    def build_token_identity(short_url)
      decode = ->(s) { UrlManagement::Infrastructure::CodecBase58.decode(s) }
      to_token = ->(url) { Token.from_short_url_standard(decode, url) }
      ValidatedRequest.from_unvalidated_request(string_to_uri, short_url:)
                      .map(&:short_url)
                      .and_then(&to_token)
                      .map(&:token_identity)
    end

    def to_original_url
      ->(s) { UrlManagement::OriginalUrl.from_string(string_to_uri, s) }
    end
  end
end
