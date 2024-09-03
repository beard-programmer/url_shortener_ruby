# frozen_string_literal: true

require_relative '../../common/result'
require_relative '../original_url'
require_relative './token_host_standard'
require_relative './encoded_url_standard'

module UrlManagement
  module Encode
    module EncodedUrl
      module_function

      def to_encoded_url(url:, token:)
        case [url, token]
        in [UrlManagement::OriginalUrl, UrlManagement::Encode::TokenStandard]
          Result.ok EncodedUrlStandard.to_encoded_url!(url:, token:)
        else
          Result.err NotImplementedError.new "Only Standard encoded urls are supported; #{url}; #{token}"
        end
      end
    end
  end
end
