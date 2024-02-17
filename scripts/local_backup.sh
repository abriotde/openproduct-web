#!/bin/bash

source config.sh

echo "Local en backup"

# cp /var/www/openproduct/wiki/LocalSettings.php var.www.openproduct.wiki.LocalSettings.php
# cp /var/www/openproduct/wiki/unsubscribe.php ../around/var.www.openproduct.wiki.unsubscribe.php
cp /etc/nginx/sites-available/openproduct ../around/etc.nginx.sites-available.openproduct
# mysqldump -uroot -posiris openproduct_wiki > $DB_BACKUP_PATH/openproduct_wiki.dump.sql
mysqldump -uroot -posiris openproduct > $DB_BACKUP_PATH/openproduct.dump.sql

