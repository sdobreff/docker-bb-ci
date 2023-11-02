FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive 


#install some base extensions
RUN apt-get update -y --fix-missing && \
	apt-get upgrade -y && \
	apt-get install -y \
	libzip-dev \
	curl \
	zip \
	git \
	vim \
	mc \
	subversion \
	golang-go \
	default-mysql-server \
	nginx \
	wget \
	rsync \
	fswatch \
	software-properties-common
#	php php-fpm php-cli php-mysqlnd php-zip php-pdo php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json php-fileinfo php-intl php-xdebug

RUN add-apt-repository ppa:ondrej/php && \
	apt update -y

RUN apt install -y php8.2 php8.2-fpm php8.2-cli php8.2-mysqlnd php8.2-zip php8.2-pdo php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath php8.2-fileinfo php8.2-intl php8.2-xdebug

RUN apt install -y php7.2 php7.2-fpm php7.2-cli php7.2-mysqlnd php7.2-zip php7.2-pdo php7.2-gd php7.2-mbstring php7.2-curl php7.2-xml php7.2-bcmath php7.2-json php7.2-fileinfo php7.2-intl php7.2-xdebug

RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
	php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# RUN composer global require pantheon-systems/terminus:2.0.0
# ENV PATH="/root/.composer/vendor/bin:${PATH}"
# ENV TERMINUS_USER_HOME=/tmp

RUN curl -sS -L https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -o /phpcs.phar \
	&& chmod +x /phpcs.phar \
	&& mv /phpcs.phar /usr/bin/phpcs

RUN git clone -b main https://github.com/sdobreff/wp-cs-extended.git wpcs \
	&& cd /wpcs \
	# && composer config allow-plugins.dealerdirect/phpcodesniffer-composer-installer true \
	# && composer require phpcsstandards/phpcsutils:^1.0 \
	&& composer update --no-dev \
	&& phpcs --config-set installed_paths /wpcs \
	&& cd /root

RUN curl -sS -L https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -o /phpcbf.phar \
	&& chmod +x /phpcbf.phar \
	&& mv /phpcbf.phar /usr/bin/phpcbf

RUN curl -sS -L https://phpmd.org/static/latest/phpmd.phar -o /phpmd.phar \
	&& chmod +x /phpmd.phar \
	&& mv /phpmd.phar /usr/bin/phpmd

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/bin/wp

USER root

RUN apt-get install -y \
	sudo

ENV HOME="/root"
ENV GOPATH="$HOME/go"
ENV PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

RUN echo $GOPATH

RUN go env -w GO111MODULE=off

RUN go get github.com/mailhog/MailHog && \
	go get github.com/mailhog/mhsendmail && \
	cp $GOPATH/bin/MailHog /usr/local/bin/mailhog && \
	cp $GOPATH/bin/mhsendmail /usr/local/bin/mhsendmail && \
	ln $GOPATH/bin/mhsendmail /usr/sbin/sendmail && \
	ln $GOPATH/bin/mhsendmail /usr/bin/mail && \
	go get github.com/prasmussen/gdrive && \
	cp $GOPATH/bin/gdrive /usr/local/bin/gdrive && \
	ln $GOPATH/bin/gdrive /usr/sbin/gdrive

### WP-CLI ###
RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O $HOME/wp-cli.phar && \
	chmod +x $HOME/wp-cli.phar && \
	mv $HOME/wp-cli.phar /usr/local/bin/wp

RUN apt-get remove apache2* -y

RUN apt-get autoremove -y

EXPOSE 8080/tcp
EXPOSE 3306/tcp
EXPOSE 8025/tcp
EXPOSE 1025/tcp

COPY default /etc/nginx/sites-available/default
COPY default-multi /etc/nginx/sites-available/default-multi
COPY default /etc/nginx/sites-available/default-8.2
COPY default-multi /etc/nginx/sites-available/default-multi-8.2
COPY default-7.2 /etc/nginx/sites-available/default-7.2
COPY default-multi-7.2 /etc/nginx/sites-available/default-multi-7.2

COPY mysql_wordpress.sql $HOME/mysql_wordpress.sql

COPY xdebug.ini /etc/php/8.2/fpm/conf.d/20-xdebug.ini
COPY xdebug.ini /etc/php/7.2/fpm/conf.d/20-xdebug.ini
COPY php.ini /etc/php/8.2/fpm/php.ini
COPY php.ini /etc/php/7.2/fpm/php.ini

# COPY bashrc $HOME/.bashrc

RUN service mysql start && \
	mysql -u root < $HOME/mysql_wordpress.sql && \
	cd /var/www/html && \
	wp --allow-root core download && \
	wp --allow-root config create --dbname=wordpress --dbuser=wordpress --dbpass=password --dbhost=127.0.0.1 && \
	wp --allow-root core install --url=some --title=test --admin_user=admin --admin_email=test@test.com --admin_password=password && \
	chown -R www-data:www-data /var/www/html && \
	wp --allow-root config set WP_HOME "https://".\$_SERVER['HTTP_HOST'] --raw && \
	wp --allow-root config set WP_SITEURL "https://".\$_SERVER['HTTP_HOST'] --raw && \
	wp --allow-root config set WP_DEBUG true --raw && \
	wp --allow-root config set WP_DEBUG_LOG true --raw && \
	wp --allow-root config set WP_DEBUG_DISPLAY false --raw && \
	wp --allow-root config set FS_METHOD direct && \
	sed -i 's/https\:\/\/\./\"https:\/\/\"\./g' wp-config.php && \
	sed -i 's/HTTP_HOST/\"HTTP_HOST\"/g' wp-config.php && \
	sed -i '2s/^/$_SERVER["HTTPS"]="on";\n/' wp-config.php && \
	wp --allow-root plugin delete hello && \
	wp --allow-root plugin delete akismet && \
	wp --allow-root plugin install wp-data-access --activate && \
	wp --allow-root plugin install wp-mail-smtp --activate && \
	wp --allow-root option update wp_mail_smtp '{"mail":{"from_email":"test@test.com","from_name":"test","mailer":"smtp","return_path":false,"from_email_force":true,"from_name_force":false},"smtp":{"autotls":true,"auth":true,"host":"127.0.0.1","encryption":"none","port":1025,"user":"","pass":"hmObKRZigL8FgPnzxqqC6GrVCQ2UB2CNa37s+5QmOQB2coXVptVSxw=="},"general":{"summary_report_email_disabled":false},"sendlayer":{"api_key":""},"smtpcom":{"api_key":"","channel":""},"sendinblue":{"api_key":"","domain":""},"gmail":{"client_id":"","client_secret":""},"mailgun":{"api_key":"","domain":"","region":"US"},"postmark":{"server_api_token":"","message_stream":""},"sendgrid":{"api_key":"","domain":""},"sparkpost":{"api_key":"","region":"US"}}' --format=json

RUN ln -s /etc/nginx/sites-available/default-multi /etc/nginx/sites-enabled/

RUN service mysql start && \
	mkdir /var/www/html-multi && \
	cd /var/www/html-multi && \
	wp --allow-root core download && \
	wp --allow-root config create --dbname=wordpress-multi --dbuser=wordpress --dbpass=password --dbhost=127.0.0.1 && \
	wp --allow-root core multisite-install --url=some-multi --title=test --admin_user=admin --admin_email=test@test.com --admin_password=password && \
	chown -R www-data:www-data /var/www/html-multi && \
	wp --allow-root config set WP_DEBUG true --raw && \
	wp --allow-root config set WP_DEBUG_LOG true --raw && \
	wp --allow-root config set WP_DEBUG_DISPLAY false --raw && \
	wp --allow-root config set FS_METHOD direct && \
	wp --allow-root plugin delete hello && \
	wp --allow-root plugin delete akismet && \
	wp --allow-root plugin install wp-data-access --activate && \
	wp --allow-root plugin install wp-mail-smtp --activate && \
	sed -i 's/'\''some-multi'\''/\$_SERVER\["HTTP_HOST"\]/g' wp-config.php && \
	sed -i '2s/^/$_SERVER["HTTPS"]="on";\n/' wp-config.php && \
	wp --allow-root option update wp_mail_smtp '{"mail":{"from_email":"test@test.com","from_name":"test","mailer":"smtp","return_path":false,"from_email_force":true,"from_name_force":false},"smtp":{"autotls":true,"auth":true,"host":"127.0.0.1","encryption":"none","port":1025,"user":"","pass":"hmObKRZigL8FgPnzxqqC6GrVCQ2UB2CNa37s+5QmOQB2coXVptVSxw=="},"general":{"summary_report_email_disabled":false},"sendlayer":{"api_key":""},"smtpcom":{"api_key":"","channel":""},"sendinblue":{"api_key":"","domain":""},"gmail":{"client_id":"","client_secret":""},"mailgun":{"api_key":"","domain":"","region":"US"},"postmark":{"server_api_token":"","message_stream":""},"sendgrid":{"api_key":"","domain":""},"sparkpost":{"api_key":"","region":"US"}}' --format=json

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils rsyslog cron
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

RUN wget https://cs.symfony.com/download/php-cs-fixer-v3.phar -O php-cs-fixer && \
	chmod a+x php-cs-fixer && \
	mv php-cs-fixer /usr/local/bin/php-cs-fixer

# Switching between PHP versions script and MySQL dumps
COPY php-switch.sh $HOME/php-switch.sh
COPY phpmyadmin.config.php $HOME/phpmyadmin.config.php
COPY restore-wordpress-multi.sh $HOME/restore-wordpress-multi.sh
COPY restore-wordpress.sh $HOME/restore-wordpress.sh

# Copy crontab file with jobs
COPY crons /usr/local/crons

# Install phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.1.4/phpMyAdmin-5.1.4-all-languages.tar.gz && \
    tar xzf phpMyAdmin-5.1.4-all-languages.tar.gz && \
	# mkdir /var/www/phpmyadmin && \
		mv phpMyAdmin-5.1.4-all-languages /var/www/html/phpmyadmin && \
		cp $HOME/phpmyadmin.config.php /var/www/html/phpmyadmin/config.inc.php

# Export MySQL DBs
RUN service mysql start && \
	mysqldump -u root wordpress > /usr/local/wordpress.sql && \
	mysqldump -u root wordpress-multi > /usr/local/wordpress-multi.sql

RUN chmod +x $HOME/php-switch.sh \
	&& mv $HOME/php-switch.sh /usr/bin/php-switch \
	&& chmod +x $HOME/restore-wordpress-multi.sh \
	&& mv $HOME/restore-wordpress-multi.sh /usr/bin/restore-wordpress-multi \
	&& chmod +x $HOME/restore-wordpress.sh \
	&& mv $HOME/restore-wordpress.sh /usr/bin/restore-wordpress

ENTRYPOINT service php8.2-fpm start && /bin/bash

EXPOSE 81/tcp
# CMD ["/usr/sbin/nginx -g 'daemon off;'"]

# docker run -d -p expoPort:contPort -t -i -v /$MOUNTED_VOLUME_DIR/$PROJECT:/$MOUNTED_VOLUME_DIR $CONTAINER_ID /bin/bash
# docker run -d -p expoPort:contPort -t -i -v /$MOUNTED_VOLUME_DIR/$PROJECT:/$MOUNTED_VOLUME_DIR $CONTAINER_ID 