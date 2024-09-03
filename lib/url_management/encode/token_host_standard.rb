# frozen_string_literal: true

module UrlManagement
  module Encode
    class TokenHostStandard
      VALUE = 'short.est'

      def host = VALUE

      def to_s = host
      def domain = host.split('.').last(2).join('.')
    end
  end
end
