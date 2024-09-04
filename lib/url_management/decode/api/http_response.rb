# frozen_string_literal: true

require 'json'
require_relative '../../../common/result'
require_relative '../../decode'
require_relative '../errors'

module UrlManagement
  module Decode
    module Api
      class HttpResponse
        private_class_method :new
        attr_reader :http_status_code, :body

        def self.from_decode_result(result)
          case result
          in Result::Ok[UrlManagement::Decode::ShortUrlDecoded[url:, short_url:]]
            new(200, { url:, short_url: }.to_json)
          in Result::Ok[UrlManagement::Decode::OriginalWasNotFound[short_url]]
            new(
              422,
              { error: { code: 'DecodedUrlWasNotFound',
                         message: "Not found original url for short: #{short_url}" } }.to_json
            )
          in Result::Err[UrlManagement::Decode::ValidationError => e]
            new(400, { error: { code: 'ValidationError', message: e } }.to_json)
          in Result::Err[UrlManagement::Decode::InfrastructureError => e]
            new(500, { error: { code: 'InfrastructureError', message: e } }.to_json)
          else raise 'Unexpected decode result'
          end
        end

        def initialize(http_status_code, body)
          @http_status_code = http_status_code
          @body = body
        end
      end
    end
  end
end
