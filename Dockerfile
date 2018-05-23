FROM php:5.6-apache

RUN echo 'mysql-server mysql-server/root_password password password' | debconf-set-selections
RUN echo 'mysql-server mysql-server/root_password_again password password' | debconf-set-selections
RUN apt-get update \
 && apt-get install -y zip unzip git libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev mysql-server nano phpunit \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite \
 && a2enmod headers \
 && docker-php-ext-install -j$(nproc) iconv mcrypt mysqli pdo_mysql gd zip \
 && service apache2 restart

# install nvm, node and npm
ENV NODE_VERSION 8.9.1
ENV NODE_PATH /root/n/bin/node
RUN curl -L https://git.io/n-install | bash -s -- -y $NODE_VERSION
RUN ln -s $NODE_PATH /usr/bin/node && ln -s $NODE_PATH /usr/bin/nodejs

COPY php.ini /usr/local/etc/php/
COPY my.cnf /etc/mysql/
COPY entrypoint.sh /entrypoint.sh

RUN find /var/lib/mysql -type f -exec touch {} \; && \
 service mysql restart && \
 mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password'" && \
 mysql -u root -ppassword -e "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));" 

VOLUME /var/www/html
WORKDIR /var/www/html

RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]

# You must add the databases and populate the database in your own dockerfile
