# frozen_string_literal: true

module UrlManagement
  module Encode
    class ValidationError < StandardError; end
    class ApplicationError < StandardError; end
    class InfrastructureError < StandardError; end
  end
end
