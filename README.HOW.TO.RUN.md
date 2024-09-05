```markdown
# Project Setup Instructions

## Prerequisites

1. **Docker**: This is required to run the PostgreSQL database using Docker Compose.
2. **Ruby 3.3.4** 
3. **Bundler**

## Step-by-Step Setup

### 1. Checkout to master

### 2. Install Ruby Dependencies

```bash
bundle install
```

### 3. Start the Database with Docker

```bash
docker-compose up -d
```

### 4. Run Database Migrations

After starting the database, you need to set up the database schema. This is done using migrations. Run the following command to apply the migrations:

```bash
bundle exec rake db:migrate
```

### 5. Running Tests

Make sure test_db is running. 
```bash
docker compose ps
```

```bash
bundle exec rspec
```

### 6. Launch the Local Server

```bash
bundle exec rackup -p 4567
```

This will start the server on port `4567`, and you can access the application by visiting `http://localhost:4567` in your browser.

### 7. [Benchmarks](./benchmarks/README.md)


### 8. Shutting Down Docker

```bash
docker-compose down
```

```