# frozen_string_literal: true

require "logger"
require_relative './lib/url_management/api'
require_relative './lib/url_management/infrastructure/event_publisher'

class App < Sinatra::Base
  configure do
    environment = ENV["APP_ENV"] || "development"
    db_config = YAML.load_file("./lib/config/database.yml")

    logger = Logger.new($stdout, level: Logger::INFO)
    Sequel.extension :migration

    db = Sequel.connect(
      db_config[environment],
      max_connections: ENV['PUMA_MAX_THREADS'] || 32,
      logger:,
      sql_log_level: :info
    ) # raises in failure

    # raises if migrations are pending.
    Sequel::Migrator.check_current(db, './lib/db/migrations')
    event_publisher = UrlManagement::Infrastructure::EventPublisher.new

    UrlManagement::Api.set(db:, event_publisher:, logger:, default_content_type: :json, show_exceptions: false)

    set :api, UrlManagement::Api
  end

  use Rack::RewindableInput::Middleware
  use Sinatra::CommonLogger, UrlManagement::Api.settings.logger

  use UrlManagement::Api
end
