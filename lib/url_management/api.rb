# frozen_string_literal: true

require "sinatra/base"
require_relative './decode/api'
require_relative './encode/api'
require_relative './encode/infrastructure'

module UrlManagement
  class Api < Sinatra::Base
    helpers do
      def db = settings.db
      def ticket_service_db = settings.ticket_service_db
      def redis = settings.redis
    end

    before do
      content_type :json
      request.body.rewind
    end

    post '/decode' do
      response = Decode::Api.handle_http(db:, logger:, body: request.body.read)
      [response.http_status_code, response.body]
    end

    post '/encode' do
      ticket_provider = lambda {
        UrlManagement::Encode::Infrastructure::RedisIdentifierProvider.produce_unique_integer(redis)
      }
      response = Encode::Api.handle_http(db:, ticket_provider:, logger:, body: request.body.read)
      [response.http_status_code, response.body]
    end

    post '/encode2' do
      ticket_provider = lambda {
        UrlManagement::Encode::Infrastructure::PostgresIdentifierProvider.produce_unique_integer(ticket_service_db)
      }
      response = Encode::Api.handle_http(db:, ticket_provider:, logger:, body: request.body.read)
      [response.http_status_code, response.body]
    end

    get '/' do
      'URL Management Service'
    end
  end
end
