FROM ubuntu:bionic
LABEL Manintainer="Gianluigi Belli <gianluigi.belli@blys.it>" Description="Dockerized bundle and useful dev tools" Version="2.1.7"

ENV TZ Europe/Rome

RUN echo $TZ > /etc/timezone && \
    apt-get update \
    && apt-get install -y \
    tzdata \
    software-properties-common \
    apt-transport-https \
    wget \
    curl \
    bash-completion \
    && rm /etc/localtime \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" \
    && add-apt-repository ppa:webupd8team/atom \
    && apt-add-repository ppa:ansible/ansible \
    && curl -sL https://deb.nodesource.com/setup_11.x | bash - \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" \
    && curl -s https://insomnia.rest/keys/debian-public.key.asc | apt-key add - \
    && add-apt-repository "deb https://dl.bintray.com/getinsomnia/Insomnia /" \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y \
    vim \
    insomnia \
    kubectl \
    python \
    python-pip \
    ssh-askpass \
    docker-ce \
    nodejs \
    yarn \
    rsync \
    build-essential \
    atom \
    code \
    ansible \
    openjdk-8-jdk \
    openjdk-8-jre \
    lsb-release \
    ca-certificates \
    php7.2 \
    php7.2-common \
    php7.2-cli \
    php7.2-dom \
    php7.2-mbstring \
    php7.2-soap \
    php7.2-curl \
    php7.2-gd \
    php7.2-zip \
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
    libappindicator3-1 \
    libgconf-2-4 \
    xdg-utils \
    fonts-liberation \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    flamerobin \
    firefox \
    libnspr4 \
    libnss3

# Install npm modules
RUN npm install -g uglify-js gulp 

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

#User definitions
ENV NBUSRHOME /netbeans

WORKDIR /tmp

#Set the entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

#Gets last stabel NetBeans
#ADD http://download.netbeans.org/netbeans/8.2/final/bundles/netbeans-8.2-linux.sh /tmp

#Install NetBeans
# RUN chmod +x netbeans-8.2-linux.sh \
#     && sleep 5 \
#     && ./netbeans-8.2-linux.sh --silent \
#     && ln -s /usr/local/netbeans-8.2/bin/netbeans /usr/local/bin/netbeans \
#     && rm -f ./netbeans-8.2-linux.sh

#Install last PHP composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

#Install last stable Chrome browser
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && (dpkg -i google-chrome-stable_current_amd64.deb || (apt-get -y -f install && dpkg -i google-chrome-stable_current_amd64.deb))

#Install last stable PHPUnit
RUN wget https://phar.phpunit.de/phpunit-8.phar \
    && chmod +x phpunit-*.phar \
    && mv phpunit-*.phar /usr/local/bin/phpunit \
    && wget https://phar.phpunit.de/phpunit-skelgen.phar \
    && chmod +x phpunit-skelgen*.phar \
    && mv phpunit-skelgen*.phar /usr/local/bin/phpunit-skelgen

#Install xdebug
RUN pecl install xdebug \
    && sh -c 'echo "zend_extension=xdebug.so" > /etc/php/7.2/mods-available/xdebug.ini' \
    && ln -s /etc/php/7.2/mods-available/xdebug.ini /etc/php/7.2/cli/conf.d/20-xdebug.ini

#Install sassy-buttons
RUN gem install sassy-buttons

# Makes bash auto-completion work and history researchable
RUN sed -i -E 's/^#\s*("\\e\[5~": history-search-backward)$/\1/g' /etc/inputrc \
    && sed -i -E 's/^#\s*("\\e\[6~": history-search-forward)$/\1/g' /etc/inputrc \
    && echo "source /etc/profile.d/bash_completion.sh" >> /etc/bash.bashrc \
    && echo "source <(kubectl completion bash)" >> /etc/bash.bashrc

#Intall python packages
RUN pip install \
    docker \
    jsondiff \
    netaddr \
    kubernetes \
    openshift \
    packaging \
    msrestazure \
    ansible[azure]

#Intall docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose \
    && curl -L https://raw.githubusercontent.com/docker/compose/1.24.1/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

#Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

#Tyde Up
RUN rm -r /tmp/* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#set the home mount point user
VOLUME $NBUSRHOME

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
