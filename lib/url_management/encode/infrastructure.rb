# frozen_string_literal: true

require 'sequel'
require_relative '../../common/result'
require_relative '../infrastructure'
require_relative './infrastructure/postgres_identifier_provider'
require_relative './infrastructure/redis_identifier_provider'

module UrlManagement
  module Encode
    module Infrastructure
      def self.codec_base58 = UrlManagement::Infrastructure::CodecBase58
      def self.parse_url_string(...) = UrlManagement::Infrastructure.parse_url_string(...)

      class DatabaseError < StandardError; end

      # @param [Sequel::Database, #insert] db
      # @param [Object] encoded_url
      def self.save_encoded_url(db, encoded_url)
        return Result.err DatabaseError.new unless encoded_url.is_a? UrlManagement::Encode::EncodedUrlStandard

        db[:encoded_urls].disable_insert_returning.insert(token_identifier: encoded_url.token.token_key,
                                                          url: encoded_url.url.to_s)
        Result.ok true
      rescue Sequel::Error => e
        Result.err DatabaseError.new(e.detailed_message)
      end
    end
  end
end
