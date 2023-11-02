#!/bin/bash

switchTo7()
{
   echo ""
   sudo update-alternatives --set php /usr/bin/php7.2

   sudo cp /etc/nginx/sites-available/default-multi-7.2 /etc/nginx/sites-available/default-multi
   sudo cp /etc/nginx/sites-available/default-7.2 /etc/nginx/sites-available/default

   sudo service php8.2-fpm stop;
   sudo service php7.2-fpm start;
   sudo service nginx restart;

   exit 1 # Exit script after printing help
}

switchTo8()
{
   echo ""
   sudo update-alternatives --set php /usr/bin/php8.2

   sudo cp /etc/nginx/sites-available/default-multi-8.2 /etc/nginx/sites-available/default-multi
   sudo cp /etc/nginx/sites-available/default-8.2 /etc/nginx/sites-available/default

   sudo service php7.2-fpm stop;
   sudo service php8.2-fpm start;
   sudo service nginx restart;

   exit 1 # Exit script after printing help
}

while getopts "78" opt
do
   case "$opt" in
      7 ) switchTo7 ;;
      8 ) switchTo8 ;;
   esac
done
