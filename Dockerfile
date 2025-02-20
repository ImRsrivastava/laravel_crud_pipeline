# Use the official PHP with Apache image
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

# Copy Apache Virtual Host configuration file
COPY laravel-crud.conf /etc/apache2/sites-available/laravel-crud.conf

# Copy Laravel application code and set ownership
COPY --chown=www-data:www-data . /var/www/html

# Set correct permissions for Laravel directories
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Install Laravel dependencies via Composer
RUN composer install --ignore-platform-reqs --no-dev --no-interaction --prefer-dist

# Clear Laravel caches and optimize
RUN php artisan config:clear
RUN php artisan route:clear
RUN php artisan view:clear

# Enable the custom Virtual Host and disable the default one
RUN a2ensite laravel-crud.conf && a2dissite 000-default.conf

# Enable Apache rewrite module
RUN a2enmod rewrite

COPY entrypoint.sh /var/www/html/entrypoint.sh
RUN chmod +x /var/www/html/entrypoint.sh

# Expose the container's port
EXPOSE 80

# Set the entrypoint to run your script
ENTRYPOINT ["/var/www/html/entrypoint.sh"]

# Start Apache server
CMD ["apache2-foreground"]
