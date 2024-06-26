#!/bin/bash

source config.sh

echo "Local backup"

# cp /var/www/openproduct/wiki/LocalSettings.php var.www.openproduct.wiki.LocalSettings.php
# cp /var/www/openproduct/wiki/unsubscribe.php ../around/var.www.openproduct.wiki.unsubscribe.php
cp /etc/nginx/sites-available/openproduct ../around/etc.nginx.sites-available.openproduct
# $MYSQLDUMP_CMD openproduct_wiki > $DB_BACKUP_PATH/openproduct_wiki.dump.sql
for table in producer produce product_link; do
	echo "Table:$table"
	$MYSQLDUMP_CMD --no-data openproduct $table | head -n -1 > $DB_BACKUP_PATH/openproduct.$table.schema.sql
	$MYSQLDUMP_CMD --no-create-info --complete-insert openproduct $table | head -n -1 > $DB_BACKUP_PATH/openproduct.$table.data.sql
done

