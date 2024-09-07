# frozen_string_literal: true

require_relative '../../../common/result'
require_relative './errors'

require 'connection_pool'

module UrlManagement
  module Encode
    module Infrastructure
      class RedisIdentifierProvider
        # @param [Redis] redis
        # @return [Result::Ok<Integer>, Result::Err<TokenSystemError>]
        # Very predictable. Can have multiple sequences with some big step
        def self.produce_unique_integer(redis)
          redis.with do |conn|
            conn.set('token_identifier', '657746689') unless conn.exists('token_identifier')

            Result.ok conn.incrby('token_identifier', 2)
          end
        rescue ConnectionPool::Error => e
          Result.err TokenSystemError.new(e)
        end
      end
    end
  end
end
