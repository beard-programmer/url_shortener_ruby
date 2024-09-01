# frozen_string_literal: true

require_relative '../../result'

module UrlManagement
  module Encode
    module EncodingHost
      class EncodingHostDefault
        VALUE = 'short.est'

        def host = VALUE

        def to_s = host
        def domain = host.split('.').last(2).join('.')
      end

      # @param [String, nil] host
      # @return [Result::Ok<EncodingHostDefault>, Result::Err<ValidationError>]
      def self.from_string(host)
        case host
        in EncodingHostDefault::VALUE | '' | nil
          Result.ok EncodingHostDefault.new
        else
          Result.err ValidationError.new("Not allowed to encode url using host #{host}")
        end
      end
    end
  end
end
