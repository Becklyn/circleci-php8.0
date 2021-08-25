FROM circleci/php:8.0-browsers

## Override CircleCI's Composer v1 with v2
RUN sudo -E php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer', 'composer-setup.php');" && \
    sudo -E php composer-setup.php --version=2.0.13 && \
    sudo -E php -r "unlink('composer-setup.php');" && \
    sudo -E rm /usr/local/bin/composer && \
    sudo -E mv composer.phar /usr/local/bin/composer && \
    sudo -E chown -R circleci:circleci /home/circleci/.config/composer

RUN sudo -E apt-get update && \
    sudo -E apt-get install -y libmagickwand-dev --no-install-recommends && \
    sudo -E pecl install imagick && \
    sudo -E docker-php-ext-enable imagick

RUN sudo -E pecl install pcov && \
    sudo -E docker-php-ext-enable pcov && \
    sudo -E rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN sudo -E apt-get update && \
    sudo -E apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    sudo -E docker-php-ext-install bcmath && \
    sudo -E docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    sudo -E docker-php-ext-install gd

RUN sudo -E docker-php-ext-install pdo_mysql mysqli && \
    sudo -E docker-php-ext-enable pdo_mysql mysqli

RUN sudo -E docker-php-ext-install pdo_mysql mysqli && \
    sudo -E docker-php-ext-enable pdo_mysql mysqli

RUN sudo -E apt-get update && \
    sudo -E apt-get install -y --no-install-recommends apt-utils

RUN sudo -E curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - && \
    sudo -E apt-get install -y nodejs build-essential && \
    sudo -E npm i -g npm node-gyp && \
    sudo -E chown -R circleci:circleci /home/circleci/.npm

RUN sudo -E -- sh -c 'touch /usr/local/etc/php/conf.d/docker-php-memlimit.ini; echo "memory_limit = -1" >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini'
RUN sudo -E -- sh -c 'echo "\n\n# NPM/NPX Settings\nexport npm_config_yes=true" >> /home/circleci/.bashrc'
RUN sudo -E -- sh -c 'echo "\n\n# NPM/NPX Settings\nexport npm_config_yes=true" >> /home/circleci/.profile'

# Somehow the permissions for this directory are set to `root:root`, which we need to change to `circleci:circleci`
# to fix some checkout errors that may also affect static code analysis scanning against old, faulty files.
RUN sudo -E chown -R circleci:circleci /home/circleci/.config
