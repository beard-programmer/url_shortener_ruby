Sequel.migration do
  up do
    run <<-SQL
      CREATE SEQUENCE identity_system.token_identifier
      AS bigint
      INCREMENT BY 1
      START WITH 656356768;
    SQL
  end

  down do
    run <<-SQL
      DROP SEQUENCE IF EXISTS identity_system.token_identifier;
    SQL
  end
end
