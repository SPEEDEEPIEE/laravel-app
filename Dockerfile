FROM php:8.2-fpm

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev

# Очистка
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Установка расширений PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Создание пользователя
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Копирование файлов приложения
COPY --chown=www:www . /var/www/html

# Установка зависимостей и настройка Git
WORKDIR /var/www/html
RUN rm -rf vendor composer.lock && \
    git config --global --add safe.directory /var/www/html && \
    composer install --no-dev --optimize-autoloader

# Права на запись для storage и bootstrap/cache
RUN chown -R www:www /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

USER www