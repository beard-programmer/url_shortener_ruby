# frozen_string_literal: true

require_relative '../../result'
require_relative './token_host_standard'

module UrlManagement
  module Encode
    module TokenHost
      module_function

      # @param [String, nil] host
      # @return [Result::Ok<TokenHostStandard>, Result::Err<ValidationError>]
      def from_string(host)
        case host
        in TokenHostStandard::VALUE | '' | nil
          Result.ok TokenHostStandard.new
        else
          Result.err ValidationError.new("Not allowed to encode url using host #{host}")
        end
      end
    end
  end
end
