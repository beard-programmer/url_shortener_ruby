# frozen_string_literal: true

require_relative '../../common/result'
require_relative './short_url_standard'

module UrlManagement
  module Decode
    module ShortUrl
      def self.from_uri(uri)
        case uri.host
        in UrlManagement::Decode::ShortUrlStandard::STANDARD_HOST
          UrlManagement::Decode::ShortUrlStandard.from_uri(uri)
        else Result.err "Custom hosts are not supported"
        end
      end
    end
  end
end
