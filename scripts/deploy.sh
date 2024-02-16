#!/bin/bash

RSYNC_CMD='rsync -avhz '
REMOTE_HOST='kaja9241@openproduct.fr'
DB_BACKUP_PATH="../../openproduct-db/db/data"

$RSYNC_CMD ../private/LocalSettings.php $REMOTE_HOST:~/public_html/wiki/LocalSettings.php
$RSYNC_CMD ../public/ --files-from=./backup_file.lst $REMOTE_HOST:~/public_html/
# particular files
$RSYNC_CMD ../around/var.www.openproduct.wiki.unsubscribe.php $REMOTE_HOST:~/public_html/unsubscribe.php
$RSYNC_CMD ../db/connection.yml $REMOTE_HOST:~/public_html/db/connection.yml
echo "Wiki DB"
$RSYNC_CMD ../around/openproduct_wiki.dump.sql $REMOTE_HOST:~/
# ssh kaja9241@openproduct.fr "mysql -ukaja9241_wiki -p kaja9241_openproduct_wiki < $DB_BACKUP_PATH/openproduct_wiki.dump.sql"
echo "DB"
$RSYNC_CMD ../around/openproduct.dump.sql $REMOTE_HOST:~/
$RSYNC_CMD ../db/connection.yml $REMOTE_HOST:~/public_html/db/
# ssh kaja9241@openproduct.fr "mysql -ukaja9241_web -p kaja9241_openproduct < $DB_BACKUP_PATH/openproduct.dump.sql"

