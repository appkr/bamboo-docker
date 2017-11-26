FROM phusion/baseimage:latest
MAINTAINER Mateusz Trojak "matisq@op.pl"
LABEL version="1.1"
LABEL description="Bamboo Agent"

# ------------------------------------------------------------------------------
# Use baseimage-docker's init system.
# ------------------------------------------------------------------------------
CMD ["/sbin/my_init"]

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /root/
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV COMPOSER_HOME /root

# ------------------------------------------------------------------------------
# Add runit service
# ------------------------------------------------------------------------------
ADD run.sh /run.sh
RUN chmod +x /*.sh

# ------------------------------------------------------------------------------
# Add locales after locale-gen as needed
# Upgrade packages on image
# Install JDK 8 (latest edition), SVN, git  and wget
# ------------------------------------------------------------------------------
RUN locale-gen en_US.UTF-8 \
    && apt-get -q update \
    && apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends \
    && apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openjdk-8-jdk \
    && apt-get -q install -y --no-install-recommends \
        subversion \
        wget \
        git \
        php-cli \
        php-gd \
        php-mcrypt \
        php-mysql \
        php-curl \
        php-mbstring \
        php-sqlite3 \
        php-xml \
    && apt-get -q autoremove \
    && apt-get -q clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /var/cache/apt/*.bin \
    && rm -f /var/tmp/*

# ------------------------------------------------------------------------------
# Install Composer
# ------------------------------------------------------------------------------
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv `pwd`/composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

# ------------------------------------------------------------------------------
# Install PHPUnit Binary
# ------------------------------------------------------------------------------
RUN wget https://phar.phpunit.de/phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/local/bin/phpunit

CMD ["/run.sh"]
