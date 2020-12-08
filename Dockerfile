FROM composer
RUN composer global require pantheon-systems/terminus:2.0.0
ENV PATH="/tmp/vendor/bin:${PATH}"
ENV TERMINUS_USER_HOME=/tmp

RUN curl -sS -L https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -o /phpcs.phar \
	&& chmod +x /phpcs.phar \
	&& mv /phpcs.phar /usr/bin/phpcs
	
RUN git clone -b master https://github.com/sdobreff/wp-coding-standards.git wpcs \
	&& phpcs --config-set installed_paths /app/wpcs

RUN curl -sS -L https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -o /phpcbf.phar \
	&& chmod +x /phpcbf.phar \
	&& mv /phpcbf.phar /usr/bin/phpcbf