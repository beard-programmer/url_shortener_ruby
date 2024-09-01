# frozen_string_literal: true

module UrlManagement
  module Encode
    class OriginalUrl
      private_class_method :new

      # @param [#parse_url_string] parser
      # @param [String] url_string
      # @return [Result::Ok<self>, Result::Err<ValidationError>]
      def self.from_string(parser, url_string)
        from_uri = lambda do |uri|
          case [uri.scheme, uri.domain]
          in ['http', nil] | ['https', nil]
            Result.err "Invalid domain for host #{uri.host}"
          in [scheme, _] unless ['http', 'https'].include? scheme
            Result.err "Invalid scheme #{scheme}"
          else
            url = new(uri:)
            Result.ok url
          end
        end

        parser.parse_url_string(url_string).and_then(&from_uri).map_err { |e| ValidationError.new(e) }
      end

      def host = uri.host
      def domain = uri.domain

      def to_s
        uri.to_s
      end

      private attr_reader :uri

      def initialize(uri:)
        @uri = uri
      end
    end
  end
end
