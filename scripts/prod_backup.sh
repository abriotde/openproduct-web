#!/bin/bash

source config.sh

SYNC_CMD="$RSYNC_CMD $REMOTE_HOST"

echo "Prod env backup"

$SYNC_CMD:~/public_html/wiki/LocalSettings.php ../private/
# $SYNC_CMD:public_html/ --files-from=backup_file.lst ../public/
# Particular files
# $SYNC_CMD:~/public_html/unsubscribe.php ../around/var.www.openproduct.wiki.unsubscribe.php
# $SYNC_CMD:~/public_html/db/connection.yml ../db/
echo " - Wiki DB"
ssh $REMOTE_HOST "mysqldump -ukaja9241_wiki -p kaja9241_openproduct_wiki" > $DB_BACKUP_PATH/openproduct_wiki.dump.sql

exit
echo " - DB : La ref est en environnement de dev"
# ssh $REMOTE_HOST "mysqldump -ukaja9241_web -p kaja9241_openproduct" > $DB_BACKUP_PATH/openproduct.dump.sql

