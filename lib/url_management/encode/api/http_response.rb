# frozen_string_literal: true

require 'json'
require_relative '../../../common/result'
require_relative '../../encode'
require_relative '../errors'

module UrlManagement
  module Encode
    module Api
      class HttpResponse
        private_class_method :new
        attr_reader :http_status_code, :body

        def self.from_encode_result(result)
          case result
          in Result::Ok[UrlManagement::Encode::UrlWasEncoded[url:, short_host:, short_token:]]
            new(200, { url:, short_url: "https://#{short_host}/#{short_token}" }.to_json)
          in Result::Err[UrlManagement::Encode::ValidationError => e]
            new(400, { error: { code: 'ValidationError', message: e } }.to_json)
          in Result::Err[UrlManagement::Encode::InfrastructureError => e]
            new(500, { error: { code: 'InfrastructureError', message: e } }.to_json)
          else raise "Unexpected encode result #{result.unwrap_err!}"
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
