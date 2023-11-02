# docker-bb-ci
Thats a docker image (you can use it in your projects via sdobreff/gitpod:latest) which will provide you with the following:
PHP 7.2 and PHP 8.2
MySQL (version may vary)
mailhog
nginx (version may vary)
WordPress - single and multi install (version may vary)
phpmyadmin - (version may vary)

admin username - `wordpress`
admin user password - `password`

wp-mail-smtp plugin is preinstalled

To swtch the PHP versions use the command `php-switch` with parameters 7 or 8

To restore the WP to its original state use `restore-wordpress` and `restore-wordpress-multi` respectively.

XDEBUG is also available on port 9001

PHP standards are preinstalled - they are custom made - more info here - https://github.com/sdobreff/wp-coding-standards
