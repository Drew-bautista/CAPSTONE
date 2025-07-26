# ----------- Build Stage ------------
FROM php:8.2.16-cli-alpine3.19 as build

# Install system dependencies, Node.js, npm, and Composer
RUN apk add --no-cache nodejs npm git unzip curl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app

# Copy composer files and install PHP dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the application
COPY . .

# Install Node dependencies and build assets
RUN npm install && npm run build

# ----------- Production Stage ------------
FROM php:8.2.16-cli-alpine3.19

# Install PHP extensions required by Laravel
RUN apk add --no-cache libpng-dev oniguruma-dev libxml2-dev zip unzip git \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

WORKDIR /app

# Copy built app from build stage
COPY --from=build /app /app

# Expose Render's default port
EXPOSE 10000

# Start Laravel server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
