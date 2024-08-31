# frozen_string_literal: true

unless defined?(Bundler)
  require "bundler/setup"
  Bundler.require
end

# Define the Sinatra application class
class Server < Sinatra::Base
  # Use middleware or handlers
  # use encode_handler
  # use decode_handler

  # Optional: Set some Sinatra configurations if needed
  configure do
    set :show_exceptions, false
  end

  # Define a simple route for the root path (optional)
  get '/' do
    'URL Management Service'
  end

  # Start the application if this file is run directly
  run! if app_file == $0
end