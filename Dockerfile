
FROM php:7.4.16-apache

#install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

#set our application folder as an environment variable
ENV APP_HOME /var/www/html

#change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

#change the web_root to laravel /var/www/html/public folder
RUN sed -i -e "s/html/html\/public/g" /etc/apache2/sites-enabled/000-default.conf

#apache log to stdout stderr
RUN echo "ErrorLog /dev/stderr" >> /etc/apache2/sites-enabled/000-default.conf
RUN echo "TransferLog /dev/stdout" >> /etc/apache2/sites-enabled/000-default.conf
RUN echo 'LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined' > /etc/apache2/conf-enabled/override-combined.conf

#enable apache module rewrite
RUN a2enmod rewrite

#copy source files and run composer
COPY . $APP_HOME

#install all PHP dependencies
RUN composer install --no-interaction

#change ownership of our applications
RUN chown -R www-data:www-data $APP_HOME

#prepare .env
RUN cp .env.example .env

RUN php artisan key:generate
