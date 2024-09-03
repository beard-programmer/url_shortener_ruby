# frozen_string_literal: true

require_relative '../../common/result'
require_relative './token_host_standard'
require_relative './token_standard'

module UrlManagement
  module Encode
    module Token
      module_function

      def issue(codec, unclaimed_identifier, token_host)
        case token_host
        in TokenHostStandard then TokenStandard.issue(codec, unclaimed_identifier, token_host)
        else
          Result.err NotImplementedError.new 'Only Standard tokens are supported!'
        end
      end
    end
  end
end
