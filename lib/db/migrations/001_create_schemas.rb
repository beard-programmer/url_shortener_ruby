# migrations/001_create_schemas.rb

Sequel.migration do
  up do
    run "CREATE SCHEMA identity_system"
  end
  down do
    run "DROP SCHEMA identity_system"
  end
end
