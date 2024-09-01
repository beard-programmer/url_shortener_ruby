# frozen_string_literal: true

require 'json-schema'

module UrlManagement
  class ApiSchemaMiddleware
    def initialize(app, schema)
      @app = app
      metaschema = JSON::Validator.validator_for_name("draft4").metaschema
      JSON::Validator.validate!(metaschema, schema)
      @schema = schema
    end

    def call(env)
      req = Rack::Request.new(env)
      if req.post? || req.put? || req.patch?
        begin
          request.body.rewind
          body = req.body.read
          JSON::Validator.validate!(@schema, body)
          env['rack.input'] = StringIO.new(body) # Rewind the input stream
        rescue JSON::Schema::ValidationError => e
          return [400, { 'Content-Type' => 'application/json' }, [{ error: e.message }.to_json]]
        end
      end
      @app.call(env)
    end
  end
end
