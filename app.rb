# frozen_string_literal: true

require "logger"
require_relative './lib/url_management/api'

class App < Sinatra::Base
  configure do
    environment = ENV["APP_ENV"] || "development"

    logger = Logger.new($stdout, level: Logger::ERROR)
    Sequel.extension :migration

    db = Sequel.connect(
      YAML.load_file("./lib/config/db.yml")[environment],
      max_connections: [(1 * ENV.fetch('PUMA_MAX_THREADS', 32).to_i), 100].min,
      logger:,
      sql_log_level: :fatal
    ) # raises in failure

    # raises if migrations are pending.
    Sequel::Migrator.check_current(db, './lib/db/migrations/db')

    ticket_service_db = Sequel.connect(
      YAML.load_file("./lib/config/ticket_service.yml")[environment],
      max_connections: [(1 * ENV.fetch('PUMA_MAX_THREADS', 32).to_i), 100].min,
      logger:,
      sql_log_level: :fatal
    ) # raises in failure
    Sequel::Migrator.check_current(ticket_service_db, './lib/db/migrations/ticket_service')

    config = YAML.load_file("./lib/config/redis.yml")[environment]

    redis = ConnectionPool.new(size: 1) do
      Redis.new(
        host: config['host'],
        port: config['port'],
        db: config['db']
      )
    end

    UrlManagement::Api.set(db:, ticket_service_db:, redis:, logger:, default_content_type: :json,
                           show_exceptions: false)
  end

  use Rack::RewindableInput::Middleware
  use Sinatra::CommonLogger, UrlManagement::Api.settings.logger

  use UrlManagement::Api
end
