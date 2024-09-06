# frozen_string_literal: true

require "logger"
require_relative './lib/url_management/api'

class App < Sinatra::Base
  configure do
    environment = ENV["APP_ENV"] || "development"

    logger = Logger.new($stdout, level: Logger::DEBUG)
    Sequel.extension :migration

    db = Sequel.connect(
      YAML.load_file("./lib/config/db.yml")[environment],
      max_connections: [(ENV.fetch('PUMA_WORKERS', 10).to_i * ENV.fetch('PUMA_MAX_THREADS', 32).to_i), 100].min / 2,
      logger:,
      sql_log_level: :debug
    ) # raises in failure

    # raises if migrations are pending.
    Sequel::Migrator.check_current(db, './lib/db/migrations/db')

    ticket_service_db = Sequel.connect(
      YAML.load_file("./lib/config/ticket_service.yml")[environment],
      max_connections: [(ENV.fetch('PUMA_WORKERS', 10).to_i * ENV.fetch('PUMA_MAX_THREADS', 32).to_i), 100].min / 2,
      logger:,
      sql_log_level: :debug
    ) # raises in failure
    Sequel::Migrator.check_current(ticket_service_db, './lib/db/migrations/ticket_service')

    UrlManagement::Api.set(db:, ticket_service_db:, logger:, default_content_type: :json, show_exceptions: false)
  end

  use Rack::RewindableInput::Middleware
  use Sinatra::CommonLogger, UrlManagement::Api.settings.logger

  use UrlManagement::Api
end
