# frozen_string_literal: true

module UrlManagement
  module Encode
    require_relative './encode/errors'
    require_relative './encode/api'
    require_relative './encode/original_url'
    require_relative './encode/encode_on_host'
    require_relative './encode/validated_request'
  end
end
