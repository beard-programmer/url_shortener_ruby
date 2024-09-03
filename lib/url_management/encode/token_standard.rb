# frozen_string_literal: true

require_relative '../../common/result'
require_relative '../simple_types'
require_relative './errors'
require_relative './token_host_standard'

module UrlManagement
  module Encode
    class TokenStandard
      private_class_method :new

      attr_reader :token, :token_key, :token_host

      def self.issue(codec, token_identifier, token_host)
        result = codec.encode(token_identifier.value).and_then do |s|
          UrlManagement::SimpleTypes::StringBase58Exp5To6.from_string(s)
        end
        return result.map_err { |e| ApplicationError.new(e) } if result.err?

        token = result.unwrap!.value
        token_key = token_identifier.value

        Result.ok new(token:, token_key:, token_host:)
      end

      # @param [String] token
      # @param [Integer] token_key
      # @param [TokenHostStandard] token_host
      def initialize(token:, token_key:, token_host:)
        raise ArgumentError, 'Not supported token host' unless token_host.is_a? TokenHostStandard

        @token = token
        @token_key = token_key
        @token_host = token_host
      end
    end
  end
end
