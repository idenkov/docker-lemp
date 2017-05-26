FROM centos:6.8

# install remi repo - needed by pretty much everything
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
 
RUN yum clean all &&\
    yum install -y epel-release wget

RUN cd /etc/yum.repos.d/ &&\
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm &&\
    rpm -Uvh remi-release-6*.rpm &&\
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi 

# cleanup image
RUN yum clean all

RUN rm -f /etc/yum.repos.d/*.rpm; rm -fr /var/cache/*

# set timezone to NYC time
RUN cp /etc/localtime /root/old.timezone && \
    rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

#Web server part
RUN rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm

RUN rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm

#Packages installation
RUN yum -y install \ 
	supervisor \
	nginx \
	nano \
	php56w-xml \
	php56w-mcrypt \
	php56w-gd \
	php56w-devel \
	#php56w-mysql \
	php56w-mbstring \
	php56w-intl \
	php56w \
	php56w-opcache \
	php56w-devel php56w-pdo \
	php56w-soap \
	php56w-xmlrpc \
	php56w-xml \
	php56w-pecl-xdebug \
	php56w-pdo \
	php56w-mysqli \
	php56w-pecl-redis \
	libwebp \
	php56w-fpm \
	php56w-common \
	gcc \
	php56w-pear \
	ImageMagick \
	ImageMagick-devel

RUN pecl install imagick
RUN echo "extension=imagick.so" > /etc/php.d/imagick.ini

RUN yum -y install rubygems
RUN gem install sass --version 3.2.13
RUN yum -y install nodejs

# Remove default nginx configs.
RUN rm -f /etc/nginx/conf.d/*

# remove man pages save space
RUN rm -fr /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/* &&\
    rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* 

# Ensure that PHP5 FPM is run as root.
RUN sed -i "s/user = www-data/user = root/" /etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = root/" /etc/php-fpm.d/www.conf

# Pass all docker environment
RUN sed -i '/^;clear_env = no/s/^;//' /etc/php-fpm.d/www.conf

# Get access to FPM-ping page /ping
RUN sed -i '/^;ping\.path/s/^;//' /etc/php-fpm.d/www.conf
# Get access to FPM_Status page /status
RUN sed -i '/^;pm\.status_path/s/^;//' /etc/php-fpm.d/www.conf

# Prevent PHP Warning: 'xdebug' already loaded.
# XDebug loaded with the core
#RUN sed -i '/.*xdebug.so$/s/^/;/' /etc/php.d/xdebug.ini

# Add configuration files
COPY conf/nginx.conf /etc/nginx/
COPY conf/supervisord.conf /etc/supervisord.conf
COPY conf/www.conf /etc/php-fpm.d/www.conf
COPY conf/php.ini /etc/php5/fpm/conf.d/40-custom.ini

################################################################################
# Volumes
################################################################################

VOLUME ["/var/www", "/etc/nginx/conf.d"]

################################################################################
# Ports
################################################################################

EXPOSE 80 443 9000

################################################################################
# Entrypoint
################################################################################

ENTRYPOINT ["/usr/bin/supervisord"]
