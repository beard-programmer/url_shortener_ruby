# frozen_string_literal: true

require "sinatra/base"
require_relative './api_schema_middleware'

module UrlManagement
  class EncodeApi < Sinatra::Base
    use(
      UrlManagement::ApiSchemaMiddleware,
      {
        "type": "object",
        "properties": {
          "url": {
            "type": "string",
            "minLength": 10,
            "description": ""

          }
        },
        "required": [
          "url"
        ]
      }
    )

    post '/encode' do
      content_type :json

      body = request.body.read
      request_hash = JSON.parse(body, symbolize_names: true)

      if request_hash[:url]
        status 200
        { url: request_hash[:url], short_url: "https://short.est/#{SecureRandom.hex(6)}" }.to_json
      else
        status 400
        { error: 'Bad input' }.to_json
      end
    rescue JSON::ParserError => e
      [400, { error: e }.to_json]
    end
  end
end
