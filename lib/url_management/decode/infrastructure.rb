# frozen_string_literal: true

require 'sequel'
require_relative '../../common/result'

module UrlManagement
  module Decode
    module Infrastructure
      class DatabaseError < StandardError; end

      # @param [Sequel::Database] db
      # @param [#value] token_identifier
      # @return [Result::Ok<String, nil>, Result::Err<DatabaseError>]
      def self.find_encoded_url(db, token_identifier)
        Result.ok db[:encoded_urls].where(token_identifier: token_identifier.value).get(:url)
      rescue Sequel::Error => e
        Result.err DatabaseError.new(e.detailed_message)
      end
    end
  end
end
