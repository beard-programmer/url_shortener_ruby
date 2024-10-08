# frozen_string_literal: true

require_relative './short_url'

module UrlManagement
  module Decode
    class RequestValidated
      attr_reader :short_url

      private_class_method :new

      def self.from_unvalidated_request(string_to_uri, request:)
        result = string_to_uri.call(request.short_url).and_then { |uri| ShortUrl.from_uri(uri) }

        result.map { |url| new(short_url: url) }
      end

      def initialize(short_url:)
        @short_url = short_url
      end
    end
  end
end
