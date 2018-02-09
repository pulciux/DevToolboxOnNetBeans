FROM openjdk:8
MAINTAINER Gianluigi Belli <gianluigi.belli@blys.it>
LABEL Description="Dockerized of NetBeans 8.2 bundle and useful dev tools" Version="1.0.0"

#User definitions
ENV NBUSRHOME /netbeans
ENV NBUSR nbuser

#adds a user to run the environment
RUN addgroup --gid 1000 $NBUSR \
    && adduser --home $NBUSRHOME --uid 1000 --disabled-password --ingroup $NBUSR $NBUSR \
    && chown -R $NBUSR:$NBUSR $NBUSRHOME

WORKDIR /tmp

#Gets last stabel NetBeans
ADD http://download.netbeans.org/netbeans/8.2/final/bundles/netbeans-8.2-linux.sh /tmp

#Install NetBeans
RUN chmod +x netbeans-8.2-linux.sh \
    && sleep 5 \
    && ./netbeans-8.2-linux.sh --silent \
    && ln -s /usr/local/netbeans-8.2/bin/netbeans /usr/local/bin/netbeans

#Install PHP, nodejs, sass, compass, git and dependencies
RUN apt-get update \
    && apt install -y \
        apt-transport-https \
        lsb-release \
        ca-certificates \
        curl \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get update \
    && apt-get install -y \
        php7.2 \
        php7.2-common \
        php7.2-cli \
        php7.2-dom \
        php7.2-mbstring \
        php7.2-soap \
        php-pear \
        php7.2-dev \
        libcurl4-openssl-dev \
        git \
        unzip \
        nodejs \
        ruby-full \
        rubygems \
        ruby-sass \
        ruby-compass \
        libappindicator1 \
        libgconf-2-4 \
        xdg-utils \
        fonts-liberation \
        libcanberra-gtk-module \
        libcanberra-gtk3-module

#Install last Firefox
RUN  sh -c 'echo "deb http://ftp.hr.debian.org/debian sid main contrib non-free" > /etc/apt/sources.list' \
    && apt-get update \
    && apt install -y -t sid firefox

#Install last PHP composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

#Install last nodejs npm
RUN npm install npm --global

#Install last stable Chrome browser
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i google-chrome-stable_current_amd64.deb

#Install last stable PHPUnit
RUN wget https://phar.phpunit.de/phpunit-7.0.phar \
    && chmod +x phpunit-7.0.phar \
    && mv phpunit-7.0.phar /usr/local/bin/phpunit \
    && wget https://phar.phpunit.de/phpunit-skelgen.phar \
    && chmod +x phpunit-skelgen.phar \
    && mv phpunit-skelgen.phar /usr/local/bin/phpunit-skelgen

#Install xdebug
RUN pecl install xdebug \
    && sh -c 'echo "zend_extension=xdebug.so" > /etc/php/7.2/mods-available/xdebug.ini' \
    && ln -s /etc/php/7.2/mods-available/xdebug.ini /etc/php/7.2/cli/conf.d/20-xdebug.ini

#Tyde Up
RUN apt-get clean cache \
    && rm -r /tmp/*

#run as unprivileged user
USER $NBUSR
WORKDIR $NBUSRHOME

VOLUME $NBUSRHOME

CMD ["netbeans"]