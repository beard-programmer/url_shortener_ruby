# frozen_string_literal: true

require_relative '../decode'
require_relative './request'
require_relative './api/http_response'

module UrlManagement
  module Decode
    module Api
      module_function

      # @param [Sequel::Database] db
      # @param [Logger] logger
      # @param [String] body
      # @return [HttpResponse]
      # @param [Object] event_publisher
      def handle_http(db:, event_publisher:, logger:, body:)
        decode_request = Request.from_json(body)

        result = decode_request.and_then do |request|
          Decode.call(db, request:)
        end

        # event_publisher.subscribe('UrlManagement::Decode::ShortUrlDecoded', add_to_cache)
        #
        # if result in Result::Ok[ShortUrlDecoded => event]
        #   event_publisher.publish(event)
        # end

        HttpResponse.from_decode_result(result)
      end
    end
  end
end
