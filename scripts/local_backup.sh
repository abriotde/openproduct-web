#!/bin/bash

source config.sh

echo "Local en backup"

# cp /var/www/openproduct/wiki/LocalSettings.php var.www.openproduct.wiki.LocalSettings.php
# cp /var/www/openproduct/wiki/unsubscribe.php ../around/var.www.openproduct.wiki.unsubscribe.php
cp /etc/nginx/sites-available/openproduct ../around/etc.nginx.sites-available.openproduct
# mysqldump -uroot -posiris openproduct_wiki > $DB_BACKUP_PATH/openproduct_wiki.dump.sql
for table in producer produce product_link; do
	echo "Table:$table"
	mysqldump -uroot -posiris --no-data openproduct $table > $DB_BACKUP_PATH/openproduct.$table.schema.sql
	mysqldump -uroot -posiris --no-create-info --complete-insert openproduct $table > $DB_BACKUP_PATH/openproduct.$table.data.sql
done

