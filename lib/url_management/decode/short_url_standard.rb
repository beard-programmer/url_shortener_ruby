# frozen_string_literal: true

require_relative '../../common/result'

module UrlManagement
  module Decode
    class ShortUrlStandard
      # @todo: move into yaml/config/db and consolidate with encode
      STANDARD_HOST = 'short.est'

      private_class_method :new

      attr_reader :path

      # @param [URI] uri
      def self.from_uri(uri)
        path = uri.path
        case [uri.scheme, uri.host, uri.domain]
        in ['http', STANDARD_HOST, String] | ['https', STANDARD_HOST, String] if 6 < path.size
          Result.ok new(path:)
        else Result.err 'Not a standard short url.'
        end
      end

      def host = STANDARD_HOST

      def initialize(path:)
        @path = path
      end
    end
  end
end
