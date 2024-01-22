#!/bin/bash

SITE_PATH=/var/www/openproduct/
WIKI_PATH=$SITE_PATH/wiki

sudo apt-get install nginx php php-fpm php-mbstring php-intl mariadb

# wiki
mkdir -p $SITE_PATH
tar -xvf mediawiki-1.40.1.tar.gz -C $SITE_PATH/
ln -s $SITE_PATH/mediawiki-1.40.1 $WIKI_PATH
cp around/var.www.openproduct.wiki.LocalSettings.php $WIKI_PATH/
cp public/img/openproduct/logoOpenProduct-128.png $WIKI_PATH/resources/assets/

# nginx
cp around/etc.nginx.sites-available.openproduct /etc/nginx/sites-available/openproduct
ln -s /etc/nginx/sites-available/openproduct /etc/nginx/sites-enable/openproduct
systemctl start nginx
systemctl enable nginx
systemctl start mariadb
systemctl enable mariadb

# APK
cd ../openproduct-app-android
./gradlew build
cp ./app/release/app-release.apk ../openproduct-web/public/data/openproduct-app.apk

# svelte
ln -s ~/Documents/OpenProduct/openproduct-web-svelte/dist/index.html ~/Documents/OpenProduct/openproduct-web/public/edit_producer.html
ln -s ~/Documents/OpenProduct/openproduct-web-svelte/dist/assets ~/Documents/OpenProduct/openproduct-web/public/assets
