# frozen_string_literal: true

module UrlManagement
  module Encode
    module Infrastructure
      class TokenSystemError < StandardError; end

      # @param [Sequel::Database, #get] db
      # @return [Ok<Integer>]
      # @return [Err<TicketSystemError>]
      def self.produce_unique_integer(db)
        f = Sequel.function(:nextval, 'token_system.token_sequence')
        Ok[db.get(f)]
      rescue Sequel::Error => e
        Err[TokenSystemError.new(e)]
      end
    end
  end
end
