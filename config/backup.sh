#!/bin/sh

rails_root=/var/www/htdocs/hdrencai

date_str=$(date "+%Y%m%d_%H%M%S")
mkdir /var/backup/hdrencai/$date_str

mongodump --db hdrencai -o /var/backup/hdrencai/$date_str

tar -zcvf /var/backup/hdrencai/$date_str/uploads.tar.gz $rails_root/public/system/
tar -zcvf /var/backup/hdrencai/$date_str/themes.tar.gz $rails_root/themes/

