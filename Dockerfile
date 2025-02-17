FROM php:8.2-apache

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

# Copy application code and set ownership while copying
COPY --chown=www-data:www-data . /var/www/html

# Set correct permissions only for necessary directories
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Install Laravel dependencies via Composer
RUN composer install --ignore-platform-reqs --no-dev

# Clear Laravel caches and optimize
RUN php artisan config:clear
RUN php artisan route:clear
RUN php artisan view:clear

# Expose the container's port
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]
