# frozen_string_literal: true

module UrlManagement
  module Infrastructure
    class EventPublisher
      def initialize
        @subscribers = Hash.new { |hash, key| hash[key] = [] }
      end

      def publish(event)
        @subscribers[event.class.name].each do |handler|
          handler.call(event)
        end
      end

      def subscribe(event_name, handler)
        @subscribers[event_name] << handler
      end
    end
  end
end
