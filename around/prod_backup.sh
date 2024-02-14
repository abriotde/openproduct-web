#!/bin/bash

RSYNC_CMD='rsync -avpzh kaja9241@openproduct.fr'

$RSYNC_CMD:~/public_html/wiki/LocalSettings.php ../private/
$RSYNC_CMD:public_html/ --files-from=backup_file.lst ../public/
# Particular files
$RSYNC_CMD:~/public_html/unsubscribe.php var.www.openproduct.wiki.unsubscribe.php
$RSYNC_CMD:~/public_html/db/connection.yml ../db/
echo "Wiki DB"
ssh kaja9241@openproduct.fr "mysqldump -ukaja9241_wiki -p kaja9241_openproduct_wiki" > openproduct_wiki.dump.sql
echo "DB"
ssh kaja9241@openproduct.fr "mysqldump -ukaja9241_web -p kaja9241_openproduct" > openproduct.dump.sql

