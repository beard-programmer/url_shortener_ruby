# frozen_string_literal: true

unless defined?(Bundler)
  require "bundler/setup"
  Bundler.require
end

require "logger"
require "yaml"

environment = ENV["APP_ENV"] || "development"
db_config = YAML.load_file("config/database.yml")

logger = Logger.new($stdout, level: Logger::DEBUG)
db = Sequel.connect(
  db_config[environment],
  logger:,
  log_connection_info: true,
  sql_log_level: :debug
) # raises in failure

require_relative './lib/url_management'

UrlManagement::Encode::Api.set(db:, logger:, default_content_type: :json, show_exceptions: false)

class Server < Sinatra::Base
  use Rack::RewindableInput::Middleware
  use Sinatra::CommonLogger, UrlManagement::Encode::Api.settings.logger

  use UrlManagement::Encode::Api

  # Define a simple route for the root path (optional)
  get '/' do
    'URL Management Service'
  end

  # Start the application if this file is run directly
  run! if app_file == $0
end
