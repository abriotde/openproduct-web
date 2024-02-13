#!/bin/bash

RSYNC_CMD='rsync -vh '
REMOTE_HOST='kaja9241@openproduct.fr'

$RSYNC_CMD ../private/LocalSettings.php $REMOTE_HOST:~/public_html/wiki/LocalSettings.php
$RSYNC_CMD ../public/ --files-from=backup_file.lst $REMOTE_HOST:~/public_html/
$RSYNC_CMD var.www.openproduct.wiki.unsubscribe.php $REMOTE_HOST:~/public_html/unsubscribe.php
echo "Wiki DB"
$RSYNC_CMD openproduct_wiki.dump.sql $REMOTE_HOST:~/
# ssh kaja9241@openproduct.fr "mysql -ukaja9241_wiki -p kaja9241_openproduct_wiki < openproduct_wiki.dump.sql"
echo "DB"
$RSYNC_CMD openproduct.dump.sql $REMOTE_HOST:~/
$RSYNC_CMD ../db/connection.yml $REMOTE_HOST:~/public_html/db/
# ssh kaja9241@openproduct.fr "mysql -ukaja9241_web -p kaja9241_openproduct < openproduct.dump.sql"

