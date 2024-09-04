# frozen_string_literal: true

require_relative '../decode'
require_relative './decode_request'
require_relative './api/http_response'

module UrlManagement
  module Decode
    module Api
      module_function

      # @param [Sequel::Database] db
      # @param [Logger] logger
      # @param [String] body
      # @return [HttpResponse]
      def handle_http(db:, logger:, body:)
        decode_request = DecodeRequest.from_json(body)

        result = decode_request.and_then do |request|
          Decode.call(db, request)
        end

        HttpResponse.from_decode_result(result)
      end
    end
  end
end
