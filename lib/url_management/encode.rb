# frozen_string_literal: true

module UrlManagement
  module Encode
    require_relative './encode/errors'
    require_relative './encode/encode'
    require_relative './encode/unclaimed_identifier'
    require_relative './encode/api'
    require_relative './encode/original_url'
    require_relative './encode/encoding_host'
    require_relative './encode/validated_request'
    require_relative './encode/infrastructure'
  end
end
