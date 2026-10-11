# AIMS backend (Laravel) for Render's free Docker web service.
# Place this file in the PROJECT ROOT (next to the aims-backend and aims-frontend-main folders).
FROM php:8.2-cli

RUN apt-get update && apt-get install -y --no-install-recommends \
      git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" pdo_mysql zip gd bcmath \
 && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY aims-backend/ /app/

RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress \
 && chmod -R 777 storage bootstrap/cache

ENV PHP_CLI_SERVER_WORKERS=4
EXPOSE 10000

# Creates any missing tables on every start, then serves the API on Render's port.
CMD ["sh", "-c", "php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=${PORT:-10000}"]
