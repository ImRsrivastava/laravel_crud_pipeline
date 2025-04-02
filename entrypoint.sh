#!/bin/sh

# Installing Required Dependencies
echo "Install dependencies..."
composer install --ignore-platform-reqs --no-dev --no-interaction --prefer-dist

# Set Git safe directory
echo "Setting Git safe directory..."
git config --global --add safe.directory /var/www/html

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

echo "Restarting Apache..."
service apache2 restart

echo "Running Apache configuration test..."
apachectl configtest

echo "Starting Apache..."
exec apache2-foreground
