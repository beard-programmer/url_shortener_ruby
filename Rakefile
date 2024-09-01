# Rakefile
require "rake"
require "sequel"
require "sequel/extensions/migration"
require "yaml"

require "rubocop/rake_task"

RuboCop::RakeTask.new do |task|
  task.requires << "rubocop-rake"
  task.requires << "rubocop-sequel"
  task.requires << "rubocop-rspec"
  task.requires << "rubocop-performance"
end

namespace :db do
  desc "Run Sequel migrations"
  task :migrate do
    db_config = YAML.load_file("lib/config/database.yml")
    environment = ENV["APP_ENV"] || "development"
    db = Sequel.connect(db_config[environment])
    Sequel::Migrator.run(db, "lib/db/migrations")

    puts "Migrations executed for #{environment} environment."
  rescue StandardError => e
    p("Rake migration aborted")
    p(e)
  end

  desc "Rollback Sequel migrations"
  task :rollback do
    db_config = YAML.load_file("lib/config/database.yml")
    environment = ENV["APP_ENV"] || "development"
    db = Sequel.connect(db_config[environment])
    Sequel::Migrator.run(db, "lib/db/migrations", target: 0)

    puts "Migrations rolled back for #{environment} environment."
  rescue StandardError => e
    p("Rake migration aborted")
    p(e)
  end
end
