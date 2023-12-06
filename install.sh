#!/bin/bash

sudo apt-get install nginx php php-fpm php-mbstring php-intl mariadb
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl start mariadb
sudo systemctl enable mariadb

mkdir -p /var/www/openproduct/
cd /var/www/openproduct/
tar -xvf mediawiki-1.40.1.tar.gz
ln -s mediawiki-1.40.1 wiki
cp var.www.openproduct.wiki.LocalSettings.php /var/www/openproduct/wiki/
cp etc.nginx.sites-available.openproduct /etc/nginx/sites-available/

