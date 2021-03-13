FROM php:7.4.16-apache-buster

#install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

#set our application folder as an environment variable
ENV APP_HOME /var/www/html

#change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

#change the web_root to laravel /var/www/html/public folder
RUN sed -i -e "s/html/html\/public/g" /etc/apache2/sites-enabled/000-default.conf

# enable apache module rewrite
RUN a2enmod rewrite

#install all the system dependencies and enable PHP modules 
RUN apt-get update && apt-get install -y \
  libicu-dev \
  libpq-dev \
  libonig-dev \
  unzip \
  && rm -r /var/lib/apt/lists/* \
  && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
  && docker-php-ext-install \
  intl \
  mbstring \
  pdo_mysql \
  opcache

COPY composer.* ./
RUN composer install --no-scripts

COPY . $APP_HOME
RUN composer run post-autoload-dump

#change ownership of our applications
RUN chown -R www-data:www-data $APP_HOME

#prepare .env
RUN cp .env.example .env


# RUN php artisan config:cache
# RUN php artisan route:cache

#update apache port at runtime for Heroku
ENTRYPOINT []
CMD sed -i "s/80/$PORT/g" /etc/apache2/sites-enabled/000-default.conf /etc/apache2/ports.conf && docker-php-entrypoint apache2-foreground ; sed -i "s/APP_KEY=/APP_KEY=${APP_KEY_ARG}/g" /var/www/html/.env
