# frozen_string_literal: true

require 'json-schema'
require_relative '../../common/result'
require_relative './errors'

module UrlManagement
  module Encode
    class Request
      private_class_method :new
      attr_reader :url

      JSON_SCHEMA =
        {
          "type": "object",
          "properties": {
            "url": {
              "type": "string",
              "minLength": 10,
              "maxLength": 255,
              "description": ""

            }
          },
          "required": [
            "url"
          ]
        }.freeze

      # @param [String] body
      # @return [Result::Ok<Request>, Result::Err<ValidationError>]
      def self.from_json(body)
        metaschema = JSON::Validator.validator_for_name("draft4").metaschema
        JSON::Validator.fully_validate_schema(metaschema, JSON_SCHEMA)
        JSON::Validator.validate!(JSON_SCHEMA, body)
        request_hash = JSON.parse(body)

        Result.ok new(request_hash.fetch('url'))
      rescue JSON::Schema::ValidationError, JSON::ParserError => e
        Result.err ValidationError.new e
      end

      def encode_at_host = nil

      def initialize(url)
        @url = url
      end
    end
  end
end
