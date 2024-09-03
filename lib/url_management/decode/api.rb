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

# #
# module UrlManagement
#   module Decode
#     class Api < Sinatra::Base
#       use(
#         ApiSchemaMiddleware,
#         {
#           "type": "object",
#           "properties": {
#             "short_url": {
#               "type": "string",
#               "minLength": 10,
#               "maxLength": 255,
#               "description": ""
#
#             }
#           },
#           "required": [
#             "short_url"
#           ]
#         }
#       )
#
#       helpers do
#         def database
#           settings.db
#         end
#
#         def logger
#           settings.logger
#         end
#       end
#
#       post '/decode' do
#         content_type :json
#
#         body = request.body.read
#         request_hash = JSON.parse(body, symbolize_names: true)
#
#         result = Decode.call(database, short_url: request_hash[:short_url])
#
#         case result
#         in Result::Err[ValidationError => e]
#           [400, { error: e }.to_json]
#         in Result::Err[InfrastructureError => e]
#           logger.info e
#           halt 500
#         in Result::Ok[Decode::DecodedUrlWasNotFound[short_url]]
#           [422, { error: "Not found original url for short: #{short_url}" }.to_json]
#         in Result::Ok[Decode::DecodedUrlWasFound[url:, short_url:]]
#           [200, { url:, short_url: }.to_json]
#         else
#           logger.info "Unexpected response from Decode: #{result}"
#           halt 500
#         end
#       rescue JSON::ParserError => e
#         [400, { error: e }.to_json]
#       end
#     end
#   end
# end
