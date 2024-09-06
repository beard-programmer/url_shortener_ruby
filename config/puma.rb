# frozen_string_literal: true

setup = {
  env: ENV['APP_ENV'] || 'development',
  port: (ENV['PORT'] || 4567).to_i,
  min_threads: (ENV['PUMA_MIN_THREADS'] || 16).to_i,
  max_threads: (ENV['PUMA_MAX_THREADS'] || 32).to_i,
  workers: (ENV['PUMA_WORKERS'] || 10).to_i
}

port        setup[:port]
environment setup[:env]
workers     setup[:workers]
threads     setup[:min_threads], setup[:max_threads]

preload_app!

before_fork do
  UrlManagement::Api.db.disconnect
  UrlManagement::Api.ticket_service_db.disconnect
end

on_worker_boot do
  UrlManagement::Api.db.disconnect
  UrlManagement::Api.ticket_service_db.disconnect
end
