# frozen_string_literal: true

module UrlManagement
  module Encode
    class EncodeOnHost
      private_class_method :new

      attr_reader :host

      def self.default
        new(host: 'short.est')
      end

      # @param [String, nil] host
      # @return [Result::Ok<self>, Result::Err<ValidationError>]
      def self.from_string(host)
        case host
        in 'short.est'
          Result.ok new(host: 'short.est')
        else
          Result.err ValidationError.new("Not allowed to encode on host #{host}")
        end
      end

      def to_s
        host
      end

      def domain
        host.split('.').last(2).join('.')
      end

      def initialize(host:)
        @host = host
      end
    end
  end
end
