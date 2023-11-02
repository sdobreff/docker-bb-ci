CREATE DATABASE wordpress;

CREATE DATABASE `wordpress-multi`;

CREATE USER `wordpress`@'%' IDENTIFIED with mysql_native_password BY 'password';

GRANT ALL PRIVILEGES ON `wordpress`.* TO 'wordpress'@'%' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON `wordpress-multi`.* TO 'wordpress'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;