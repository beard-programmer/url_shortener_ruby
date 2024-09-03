# frozen_string_literal: true

require_relative '../../common/result'
require_relative '../simple_types'

module UrlManagement
  module Decode
    class Token
      private_class_method :new

      attr_reader :token_identity, :token_host

      # @param [ShortUrlStandard] short_url
      # @param [Object] decode_token_key
      def self.from_short_url_standard(decode_token_key, short_url)
        host = short_url.host

        decoded_token = SimpleTypes::StringBase58Exp5To6.from_string(short_url.path[1..]).and_then do |key|
          decode_token_key.call(key.value)
        end
        token_identity = decoded_token.and_then do |token_key|
          SimpleTypes::IntegerBase58Exp5To6.from_integer(token_key)
        end
        token_identity.map do |value|
          new(token_identity: value, token_host: host)
        end
      end

      def initialize(token_identity:, token_host:)
        @token_identity = token_identity
        @token_host = token_host
      end
    end
  end
end
