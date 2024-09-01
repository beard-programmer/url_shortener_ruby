# frozen_string_literal: true

require_relative './original_url'
require_relative './token_standard'

module UrlManagement
  module Encode
    class EncodedUrlStandard
      private_class_method :new

      attr_reader :url, :token

      def self.to_encoded_url!(url:, token:)
        raise ArgumentError unless [url, token] in [OriginalUrl, TokenStandard]

        new(url:, token:)
      end

      def initialize(url:, token:)
        @url = url
        @token = token
      end
    end
  end
end
