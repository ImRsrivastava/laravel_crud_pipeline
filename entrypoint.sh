#!/bin/sh

echo "Waiting for MySQL to be ready..."
until php artisan migrate:status > /dev/null 2>&1; do
    echo "Waiting for MySQL..."
    sleep 3
done
echo "MySQL is ready!"

echo "Running migrations..."
php artisan migrate --force

echo "Clearing caches..."
php artisan config:cache
php artisan route:cache

echo "Setting up permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

echo "Starting Apache..."
exec apache2-foreground
