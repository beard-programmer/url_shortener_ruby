# frozen_string_literal: true

require "sinatra/base"
require_relative '../api_schema_middleware'

module UrlManagement
  module Encode
    class Api < Sinatra::Base
      use(
        UrlManagement::ApiSchemaMiddleware,
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
        }
      )

      helpers do
        def database
          settings.db
        end
      end

      post '/encode' do
        content_type :json

        body = request.body.read
        request_hash = JSON.parse(body, symbolize_names: true)

        result = Encode.call(
          -> { Infrastructure.produce_unique_integer(database) },
          ->(url) { Infrastructure.save_encoded_url(database, url) },
          url: request_hash[:url]
        )

        if result.ok?
          status 200
          encoded_url = result.unwrap!
          url = encoded_url.url.to_s
          token = encoded_url.token
          short_url = "https://#{token.token_host}/#{token.token}"
          { url:, short_url: }.to_json
        else
          status 400
          { error: result.unwrap_err!.to_s }.to_json
        end
      rescue JSON::ParserError => e
        [400, { error: e }.to_json]
      end
    end
  end
end
