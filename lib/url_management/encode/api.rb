# frozen_string_literal: true

require_relative '../encode'
require_relative './request'
require_relative './infrastructure'
require_relative './api/http_response'

module UrlManagement
  module Encode
    module Api
      module_function

      # @param [Sequel::Database] db
      # @param [Logger] logger
      # @param [String] body
      # @return [HttpResponse]
      def handle_http(db:, logger:, body:)
        logger.info body
        encode_request = Request.from_json(body)

        result = encode_request.and_then do |request|
          Encode.call(
            -> { Infrastructure.produce_unique_integer(db) },
            ->(url) { Infrastructure.save_encoded_url(db, url) },
            request:
          )
        end

        HttpResponse.from_encode_result(result)
      end
    end
  end
end
