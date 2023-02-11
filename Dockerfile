FROM php:8.0-fpm

COPY composer.lock composer.json /var/www/html/

WORKDIR /var/www/html


ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \install-php-extensions mbstring pdo_mysql zip exif pcntl gd

RUN apt-get update && apt-get install -y \
    git \
    exif \
    curl \
    libzip-dev \
    libpng-dev \
    jpegoptim \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    zip \
    build-essential \
    locales \
    unzip \
    libwebp-dev \
    libpq-dev

RUN curl -sL http://www.lcdf.org/gifsicle/gifsicle-1.91.tar.gz | tar -zx && cd gifsicle-1.91 && ./configure --disable-gifview make install

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
#RUN docker-php-ext-configure zip
RUN docker-php-ext-install mbstring bcmath
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd

COPY . /var/www/html


RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www/html

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

USER www


EXPOSE 9000
CMD ["php-fpm"]