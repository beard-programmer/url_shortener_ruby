# frozen_string_literal: true

require_relative '../simple_types'
require_relative './encoding_host'

module UrlManagement
  module Encode
    module UnclaimedToken
      class StandardUnclaimedToken
        private_class_method :new

        attr_reader :token, :token_key, :token_host

        def self.issue(codec, unclaimed_identifier, token_host)
          result = codec.encode(unclaimed_identifier.value).and_then do |s|
            UrlManagement::SimpleTypes::StringBase58Exp5To6.from_string(s)
          end
          return result.map_err { |e| ApplicationError.new(e) } if result.err?

          token = result.unwrap!.value
          token_key = unclaimed_identifier.value

          Result.ok new(token:, token_key:, token_host:)
        end

        # @param [String] token
        # @param [Integer] token_key
        # @param [EncodingHost::EncodingHostDefault] token_host
        def initialize(token:, token_key:, token_host:)
          raise ArgumentError, 'Not supported token host' unless token_host.is_a? EncodingHost::EncodingHostDefault

          @token = token
          @token_key = token_key
          @token_host = token_host
        end
      end

      def self.issue(codec, unclaimed_identifier, token_host)
        case token_host
        in EncodingHost::EncodingHostDefault then StandardUnclaimedToken.issue(codec, unclaimed_identifier, token_host)
        else
          Result.err NotImplementedError.new
        end
      end
    end
  end
end
