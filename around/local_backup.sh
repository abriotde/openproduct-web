#!/bin/bash

# cp /var/www/openproduct/wiki/LocalSettings.php var.www.openproduct.wiki.LocalSettings.php
cp /var/www/openproduct/wiki/unsubscribe.php var.www.openproduct.wiki.unsubscribe.php
cp /etc/nginx/sites-available/openproduct etc.nginx.sites-available.openproduct
mysqldump -uroot -posiris openproduct_wiki > openproduct_wiki.dump.sql
mysqldump -uroot -posiris openproduct > openproduct.dump.sql

