# Use the official PHP 8.2 image with Apache
FROM php:8.2-apache

# Set the working directory in the container
WORKDIR /var/www/html

# Install necessary system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    curl \
    libzip-dev \
    zlib1g-dev \
    libpng-dev \
    libonig-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libxml2-dev \
    git \
    libicu-dev \
    default-mysql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
    zip \
    mysqli \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    intl

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy application code into the container
COPY . /var/www/html/

# Set file permissions for Apache user
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Install Laravel dependencies via Composer
RUN composer install --ignore-platform-reqs --no-dev

# Clear Laravel caches and optimize
RUN php artisan optimize:clear
RUN php artisan config:clear
RUN php artisan route:clear
RUN php artisan view:clear

# Run migrations (optional, only if you want to do this on build)
RUN php artisan migrate --force

# Expose the container's port
EXPOSE 8000

# Start Apache server
CMD ["apache2-foreground"]