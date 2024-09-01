Sequel.migration do
  up do
    run <<-SQL
      CREATE TABLE encoded_urls (
          token_identifier BIGINT PRIMARY KEY,
          url VARCHAR(255) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    SQL
  end

  down do
    run 'DROP TABLE encoded_urls'
  end
end
