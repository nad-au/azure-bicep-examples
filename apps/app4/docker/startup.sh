#!/bin/sh

cd /var/www
export NGINX_PORT=8080

defined_envs=$(printf '${%s} ' $(env | cut -d= -f1))
envsubst "$defined_envs" < /etc/nginx/templates/sites.conf.template > /etc/nginx/sites-available/default

echo 'Running migrations'
chown -R www-data:www-data /var/www/

if [  -n "$PHP_ORIGIN" ] && [ "$PHP_ORIGIN" = "php-fpm" ]; then
   export NGINX_DOCUMENT_ROOT='/var/www/public'
   service nginx restart
else
   export APACHE_DOCUMENT_ROOT='/var/www/public'
fi
