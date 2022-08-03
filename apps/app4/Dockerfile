FROM node:14.18.0 as builder

ARG ENV_FILE
ENV ENV_FILE=${ENV_FILE}

WORKDIR /var/www
COPY . /var/www

FROM appsvc/php:8.0-fpm_20211102.4

WORKDIR /var/www
# docker-compose wait tool
ENV WAIT_VERSION 2.8.0
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait /wait
RUN chmod +x /wait

RUN apt-get update -y && apt-get install -y openssl zip unzip git
RUN docker-php-ext-install pdo pdo_mysql sockets
RUN curl -sS https://getcomposer.org/installer | php -- \
     --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /etc/nginx/templates

COPY docker/config/nginx/sites.conf /etc/nginx/templates/sites.conf.template
COPY docker/startup.sh /startup.sh
RUN chmod +x /startup.sh

# Copy existing application directory contents
COPY --chown=www-data:www-data --from=builder /var/www .
RUN composer update
RUN composer install --no-ansi --no-interaction --no-scripts --optimize-autoloader --quiet
RUN chown -R www-data:www-data /var/www


CMD ["/startup.sh"]
