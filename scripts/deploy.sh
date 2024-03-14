#!/bin/bash

source config.sh

echo "Deploy on prod"

# ./departements.jl
# ./docsToWeb.jl
# ./generateStaticProducerHTML.jl
./producersDB2JSON.jl

$RSYNC_CMD ../private/LocalSettings.php $REMOTE_HOST:~/public_html/wiki/LocalSettings.php
$RSYNC_CMD ../public/ --files-from=./backup_file.lst $REMOTE_HOST:~/public_html/
# particular files
$RSYNC_CMD ../around/var.www.openproduct.wiki.unsubscribe.php $REMOTE_HOST:~/public_html/unsubscribe.php
$RSYNC_CMD ../db/connection.yml $REMOTE_HOST:~/public_html/db/connection.yml

exit;

echo "Wiki DB : La prod est la ref"
$RSYNC_CMD ../around/openproduct_wiki.dump.sql $REMOTE_HOST:~/
# ssh kaja9241@openproduct.fr "mysql -ukaja9241_wiki -p kaja9241_openproduct_wiki < $DB_BACKUP_PATH/openproduct_wiki.dump.sql"
echo "DB : Pas essentiel (Juste pour sendMail=Never)"
$RSYNC_CMD ../around/openproduct.dump.sql $REMOTE_HOST:~/
$RSYNC_CMD ../db/connection.yml $REMOTE_HOST:~/public_html/db/
ssh $REMOTE_HOST "mysql -ukaja9241_web -p kaja9241_openproduct < $DB_BACKUP_PATH/openproduct.dump.sql"

