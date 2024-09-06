# frozen_string_literal: true

require 'sequel'
require_relative '../../common/result'

module UrlManagement
  module Infrastructure
    class TokenSystemError < StandardError; end

    # @param [Sequel::Database, #get] db
    # @return [Result::Ok<Integer>, Result::Err<TokenSystemError>]
    # Very predictable. Can have multiple sequences with some big step
    # @todo: forbid setval.
    def self.produce_unique_integer(db)
      f = Sequel.function(:nextval, 'identity_system.token_identifier')
      Result.ok db.get(f)
    rescue Sequel::Error => e
      Result.err TokenSystemError.new(e)
    end
  end
end
