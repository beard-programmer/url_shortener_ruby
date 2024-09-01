# frozen_string_literal: true

require_relative '../simple_types'
require_relative './token_host'
require_relative './token_standard'

module UrlManagement
  module Encode
    module Token
      module_function

      def issue(codec, unclaimed_identifier, token_host)
        case token_host
        in TokenHostStandard then TokenStandard.issue(codec, unclaimed_identifier, token_host)
        else
          Result.err NotImplementedError.new
        end
      end
    end
  end
end
