# frozen_string_literal: true

require_relative '../../common/result'
require_relative '../infrastructure'

module UrlManagement
  module Decode
    module Infrastructure
      def self.codec_base58 = UrlManagement::Infrastructure::CodecBase58
      def self.parse_url_string(...) = UrlManagement::Infrastructure.parse_url_string(...)

      class DatabaseError < StandardError; end

      # @param [Sequel::Database] db
      # @param [#value] token_identifier
      # @return [Result::Ok<String, nil>, Result::Err<DatabaseError>]
      def self.find_encoded_url(db, token_identifier)
        Result.ok db[:encoded_urls].where(token_identifier: token_identifier.value).get(:url)
      rescue StandardError => e
        Result.err DatabaseError.new(e.detailed_message)
      end
    end
  end
end
