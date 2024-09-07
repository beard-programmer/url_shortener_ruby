# frozen_string_literal: true

require 'sequel'
require_relative '../../../common/result'

module UrlManagement
  module Encode
    module Infrastructure
      module PostgresIdentifierProvider
        class TokenSystemError < StandardError; end

        module_function

        # @param [Sequel::Database, #get] ticket_service_db
        # @return [Result::Ok<Integer>, Result::Err<TokenSystemError>]
        # Very predictable. Can have multiple sequences with some big step
        def produce_unique_integer(ticket_service_db)
          f = Sequel.function(:nextval, 'token_identifier')
          Result.ok ticket_service_db.get(f)
        rescue Sequel::Error => e
          Result.err TokenSystemError.new(e)
        end
      end
    end
  end
end
