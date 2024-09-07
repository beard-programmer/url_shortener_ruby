Sequel.migration do
  up do
    run <<-SQL
      ALTER SEQUENCE token_identifier
      INCREMENT BY 2
      RESTART WITH 657865857
    SQL
  end

  down do
    run <<-SQL
      ALTER SEQUENCE token_identifier
      INCREMENT BY 1
    SQL
  end
end
