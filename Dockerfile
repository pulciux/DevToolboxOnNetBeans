FROM ubuntu:bionic
MAINTAINER Gianluigi Belli <gianluigi.belli@blys.it>
LABEL Description="Dockerized of NetBeans 8.2 bundle and useful dev tools" Version="1.2.2"

ENV TZ Europe/Rome

RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata software-properties-common && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#User definitions
ENV NBUSRHOME /netbeans

WORKDIR /tmp

#Set the entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

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
        openssl \
        ruby-full \
        rubygems \
        ruby-sass \
        ruby-compass \
        libappindicator1 \
        libgconf-2-4 \
        xdg-utils \
        fonts-liberation \
        libcanberra-gtk-module \
        libcanberra-gtk3-module \
        firefox \
        libnspr4 \
        libnss3

#Install last PHP composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

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

#Install nodejs
RUN apt install nodejs npm -y

#Install sassy-buttons
RUN gem install sassy-buttons

#Install uglify
RUN npm install uglify-js -g

#Tyde Up
RUN apt-get clean cache \
    && rm -r /tmp/*

#set the home mount point user
VOLUME $NBUSRHOME

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["netbeans"]