setup = {
  env: ENV['APP_ENV'] || 'development',
  port: (ENV['PORT'] || 4567).to_i,
  min_threads: (ENV['PUMA_MIN_THREADS'] || 32).to_i,
  max_threads: (ENV['PUMA_MAX_THREADS'] || 32).to_i,
  workers: (ENV['PUMA_WORKERS'] || 10).to_i
}

port        setup[:port]
environment setup[:env]
workers     setup[:workers]
threads     setup[:min_threads], setup[:max_threads]

preload_app!

on_worker_boot do
  puts 'Worker booting...'
  puts 'Disconnecting db'

  App.api.settings.db.disconnect
  puts 'Disconnected db'

  # puts App.api.settings.db.disconnect

  # ENV.fetch("APP_ENV", "development")
  # YAML.load_file("./lib/config/database.yml")

  # Reconnect the database for this specific worker
  # db = App.api.db
  # db.disconnect
  # App.api.settings.set :db, db
end
