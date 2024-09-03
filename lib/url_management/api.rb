# frozen_string_literal: true

require "sinatra/base"
require_relative './decode/api'
require_relative './encode/api'

module UrlManagement
  class Api < Sinatra::Base
    before do
      content_type :json
      request.body.rewind
    end

    post '/decode' do
      response = Decode::Api.handle_http(db: settings.db, logger: settings.logger, body: request.body.read)
      [response.http_status_code, response.body]
    end

    post '/encode' do
      Encode::Api.handle(request.body.read, settings.db, settings.logger)
    end

    get '/' do
      'URL Management Service'
    end
  end
end
