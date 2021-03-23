FROM ubuntu:20.04

RUN apt-get update

# locales
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV TZ=Pacific/Auckland
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Nginx, vim, supervisor, wget
RUN apt-get install -y  \
	nginx  \
	vim \
	wget \
	supervisor

# Usefull stuff
RUN apt-get install -y software-properties-common

# PHP
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y \
	php7.4-fpm \
	php7.4-cli \
	php7.4-gd \
	php7.4-mysql \
	php7.4-intl \
	php7.4-zip \
	php7.4-redis \
	php7.4-imap \
	php7.4-memcached \
	php7.4-mbstring \
	php7.4-xml \
	php7.4-curl \
	php7.4-bcmat
	
RUN mkdir /run/php

# Composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Cleaning up
RUN apt-get remove -y --purge software-properties-common
RUN apt-get -y autoremove
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get clean

# Send output to console
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Install new RDS certs
RUN wget https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem \
  && mkdir /usr/local/share/ca-certificates/aws \
  && mv rds-ca-2019-root.pem /usr/local/share/ca-certificates/aws \
  && openssl x509 \
    -in /usr/local/share/ca-certificates/aws/rds-ca-2019-root.pem \
    -inform PEM \
    -out /usr/local/share/ca-certificates/aws/rds-ca-2019-root.crt \
  && update-ca-certificates

# Copy Nginx and PHP configuration
COPY .aws/image/config/nginx/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
COPY .aws/image/config/nginx/settings.conf /etc/nginx/snippets/settings.conf
COPY .aws/image/config/nginx/default.conf /etc/nginx/sites-available/default
COPY .aws/image/config/php/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf
COPY .aws/image/config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure app setting are available in App
RUN sed -i 's/;clear_env = no/clear_env = no/g' /etc/php/7.4/fpm/pool.d/www.conf

# php-fpm setting
RUN sed -i 's/pm = dynamic/pm = static/g' /etc/php/7.4/fpm/pool.d/www.conf
RUN sed -i 's/;pm.max_requests = 500/pm.max_requests = 500/g' /etc/php/7.4/fpm/pool.d/www.conf
RUN sed -i "s/pm.max_children = 5/pm.max_children = 150/g" /etc/php/7.4/fpm/pool.d/www.conf

COPY --chown=www-data:www-data . /var/www/html

COPY .aws/image/init_container.sh /opt/startup/
RUN chmod 755 /opt/startup/init_container.sh

EXPOSE 80 443

WORKDIR /var/www/html
