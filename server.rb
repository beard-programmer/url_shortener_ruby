# frozen_string_literal: true

unless defined?(Bundler)
  require "bundler/setup"
  Bundler.require
end

require "logger"
require "yaml"

environment = ENV["APP_ENV"] || "development"
db_config = YAML.load_file("lib/config/database.yml")

logger = Logger.new($stdout, level: Logger::DEBUG)
Sequel.extension :migration
db = Sequel.connect(
  db_config[environment],
  logger:,
  log_connection_info: true,
  sql_log_level: :debug
) # raises in failure

Sequel::Migrator.check_current(db, './lib/db/migrations')

require_relative './lib/url_management'

UrlManagement::Encode::Api.set(db:, logger:, default_content_type: :json, show_exceptions: false)

class Server < Sinatra::Base
  use Rack::RewindableInput::Middleware
  use Sinatra::CommonLogger, UrlManagement::Encode::Api.settings.logger

  use UrlManagement::Encode::Api

  get '/' do
    'URL Management Service'
  end

  run! if app_file == $0
end
