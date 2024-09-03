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
require_relative './lib/url_management/api'
require_relative './lib/url_management/encode/api'
require_relative './lib/url_management/decode/api'

# UrlManagement::Encode::Api.set(db:, logger:, default_content_type: :json, show_exceptions: false)
# UrlManagement::Decode::Api.set(db:, logger:, default_content_type: :json, show_exceptions: false)
UrlManagement::Api.set(db:, logger:, default_content_type: :json, show_exceptions: false)

class Server < Sinatra::Base
  use Rack::RewindableInput::Middleware
  # use Sinatra::CommonLogger, UrlManagement::Decode::Api.settings.logger
  use Sinatra::CommonLogger, UrlManagement::Api.settings.logger

  use UrlManagement::Api
  # use UrlManagement::Encode::Api
  # use UrlManagement::Decode::Api

  # get '/' do
  #   'URL Management Service'
  # end

  run! if app_file == $0
end
