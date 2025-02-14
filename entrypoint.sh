#!/bin/sh

echo "Waiting for MySQL to be ready..."
sleep 10

echo "Running migrations..."
php artisan migrate --force

# Capture the port from the .env file or use the default 8081 from docker-compose.yml
PORT=$(grep -oP '(?<=^CONTAINER_PORT=).*' .env)
PORT=${PORT:-8000}  # Default to 8000 if not set in .env

echo "Starting Laravel project on port $PORT..."
exec php artisan serve --host 0.0.0.0 --port $PORT

echo "Starting Apache..."
exec apache2-foreground

