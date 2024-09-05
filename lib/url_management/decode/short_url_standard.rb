# frozen_string_literal: true

require_relative '../../common/result'
require_relative '../simple_types'

module UrlManagement
  module Decode
    class ShortUrlStandard
      # @todo: move into yaml/config/db and consolidate with encode
      STANDARD_HOST = 'short.est'

      private_class_method :new

      attr_reader :path, :token

      # @param [URI] uri
      def self.from_uri(uri)
        path = uri.path
        to_token = SimpleTypes::StringBase58Exp5To6.from_string(uri.path[1..])

        case [uri.scheme, uri.host, uri.domain, to_token.ok?]
        in ['http', STANDARD_HOST, String, true] | ['https', STANDARD_HOST, String, true] if 6 < path.size
          Result.ok new(path:, token: to_token.unwrap!.value)
        else Result.err 'Not a standard short url.'
        end
      end

      def host = STANDARD_HOST

      def initialize(path:, token:)
        @path = path
        @token = token
      end
    end
  end
end
