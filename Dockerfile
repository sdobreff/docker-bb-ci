FROM php:7.4.1-fpm

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apt-get update --fix-missing
#install some base extensions
RUN apt-get install -y \
	libzip-dev \
	zip \
	git \
	subversion \
	&& docker-php-ext-install zip

RUN composer global require pantheon-systems/terminus:2.0.0
ENV PATH="/root/.composer/vendor/bin:${PATH}"
ENV TERMINUS_USER_HOME=/tmp

RUN curl -sS -L https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -o /phpcs.phar \
	&& chmod +x /phpcs.phar \
	&& mv /phpcs.phar /usr/bin/phpcs

RUN git clone -b master https://github.com/sdobreff/wp-coding-standards.git wpcs \
	&& phpcs --config-set installed_paths /var/www/html/wpcs

RUN curl -sS -L https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -o /phpcbf.phar \
	&& chmod +x /phpcbf.phar \
	&& mv /phpcbf.phar /usr/bin/phpcbf

RUN curl -sS -L https://phpmd.org/static/latest/phpmd.phar -o /phpmd.phar \
	&& chmod +x /phpmd.phar \
	&& mv /phpmd.phar /usr/bin/phpmd

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/bin/wp
