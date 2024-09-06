Sequel.migration do
  up do
    run <<-SQL
      CREATE SEQUENCE token_identifier
      AS bigint
      INCREMENT BY 1
      START WITH 657508406;
    SQL
  end

  down do
    run <<-SQL
      DROP SEQUENCE IF EXISTS token_identifier;
    SQL
  end
end
