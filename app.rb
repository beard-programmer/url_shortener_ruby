# frozen_string_literal: true

require "logger"
require_relative './lib/url_management/api'
require_relative './lib/url_management/infrastructure/event_publisher'

class App < Sinatra::Base
  configure do
    environment = ENV["APP_ENV"] || "development"
    db_config = YAML.load_file("./lib/config/database.yml")

    logger = Logger.new($stdout, level: Logger::DEBUG)
    Sequel.extension :migration

    db = Sequel.connect(
      db_config[environment],
      max_connections: [(ENV.fetch('PUMA_WORKERS', 10).to_i * ENV.fetch('PUMA_MAX_THREADS', 32).to_i), 100].min,
      logger:,
      sql_log_level: :debug
    ) # raises in failure

    # raises if migrations are pending.
    Sequel::Migrator.check_current(db, './lib/db/migrations')

    UrlManagement::Api.set(db:, logger:, default_content_type: :json, show_exceptions: false)
  end

  use Rack::RewindableInput::Middleware
  use Sinatra::CommonLogger, UrlManagement::Api.settings.logger

  use UrlManagement::Api
end
