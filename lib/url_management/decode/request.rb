# frozen_string_literal: true

require 'json-schema'
require_relative '../../common/result'
require_relative './errors'

module UrlManagement
  module Decode
    class Request
      private_class_method :new
      attr_reader :short_url

      JSON_SCHEMA =
        {
          "type": "object",
          "properties": {
            "short_url": {
              "type": "string",
              "minLength": 10,
              "maxLength": 255,
              "description": ""

            }
          },
          "required": [
            "short_url"
          ]
        }.freeze

      # @param [String] body
      # @return [Result::Ok<Request>, Result::Err<ValidationError>]
      def self.from_json(body)
        metaschema = JSON::Validator.validator_for_name("draft4").metaschema
        JSON::Validator.validate!(metaschema, JSON_SCHEMA)
        JSON::Validator.validate!(JSON_SCHEMA, body)
        request_hash = JSON.parse(body)

        Result.ok new(request_hash.fetch('short_url'))
      rescue JSON::Schema::ValidationError, JSON::ParserError => e
        Result.err ValidationError.new e
      end

      def initialize(short_url)
        @short_url = short_url
      end
    end
  end
end
