# frozen_string_literal: true

require "sinatra/base"
require_relative './decode/api'
require_relative './encode/api'

module UrlManagement
  class Api < Sinatra::Base
    helpers do
      def db = settings.db
      def event_publisher = settings.event_publisher
    end

    before do
      content_type :json
      request.body.rewind
    end

    post '/decode' do
      response = Decode::Api.handle_http(db:, event_publisher:, logger:, body: request.body.read)
      [response.http_status_code, response.body]
    end

    post '/encode' do
      response = Encode::Api.handle_http(db:, event_publisher:, logger:, body: request.body.read)
      [response.http_status_code, response.body]
    end

    get '/' do
      'URL Management Service'
    end
  end
end
