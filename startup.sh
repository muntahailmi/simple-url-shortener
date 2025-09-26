#!/bin/bash

# Move sample config to actual config
mv config.sample.php config.php

# Update Apache configuration to allow .htaccess overrides
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

# Set ServerName in Apache configuration
echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Connect and setup database credentials
DB_PASSWORD="${DB_PASS}"
DB_HOST="${DB_HOST}"
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"

# Temporary files
REMOTE_SCHEMA="/tmp/remote_schema.sql"
LOCAL_SCHEMA="/tmp/local_schema.sql"

SQL_FILE="/var/www/html/database.sql"

# Wait for MySQL to be ready
until mysql -u $DB_USER -p"$DB_PASSWORD" -h "$DB_HOST" -P 3306 -e "SELECT 1"; do
    echo "Waiting for MySQL to be ready..."
    sleep 2
done

# Temporary files
REMOTE_SCHEMA="/tmp/remote_schema.sql"
LOCAL_SCHEMA="/tmp/local_schema.sql"

# Extract the remote database schema
mysql -u $DB_USER -p"$DB_PASSWORD" -h "$DB_HOST" -P 3306 -D "$DB_NAME" -e "SHOW TABLES;" | grep -v Tables_in_ > tables.txt
for table in $(cat tables.txt); do
  mysql -u $DB_USER -p"$DB_PASSWORD" -h "$DB_HOST" -P 3306 -D "$DB_NAME" -e "SHOW CREATE TABLE $table;" --raw -N --batch | cut -f2 | sed "$d" >> $REMOTE_SCHEMA
done

# Extract the local database schema
grep -E "^CREATE TABLE" $SQL_FILE | while read -r line ; do
  table_name=$(echo $line | awk '{print $3}')
  sed -n "/^CREATE TABLE $table_name/,/;/p" $SQL_FILE | sed "$d" >> $LOCAL_SCHEMA
done

# Compare the schemas
if diff $REMOTE_SCHEMA $LOCAL_SCHEMA > /dev/null; then
  echo "Schemas match. Skipping the import."
else
  echo "Schemas do not match. Importing the database."
  mysql -u $DB_USER -p"$DB_PASSWORD" -h "$DB_HOST" -P 3306 -D "$DB_NAME" < $SQL_FILE
fi

# Clean up
rm tables.txt $REMOTE_SCHEMA $LOCAL_SCHEMA

# Update the config.php file with database credentials
sed -i "s|\$dbhost = ''|\$dbhost = '$DB_HOST'|; s|\$dbuser = ''|\$dbuser = '$DB_USER'|; s|\$dbpass = ''|\$dbpass = '$DB_PASSWORD'|; s|\$dbname = ''|\$dbname = '$DB_NAME'|" /var/www/html/config.php

systemctl restart apache2

# Start Apache in the foreground
apache2ctl -D FOREGROUND
