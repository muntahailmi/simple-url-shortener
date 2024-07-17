#!/bin/bash

# Move sample config to actual config
mv config.sample.php config.php

# Update Apache configuration to allow .htaccess overrides
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

# Set ServerName in Apache configuration
echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Connect and setup database credentials
DB_PASSWORD="{DB_PASS}"
DB_HOST="{DB_HOST}"
DB_NAME="{DB_NAME}"
DB_USER="admin"

# Wait for MySQL to be ready
until mysql -u $DB_USER -p"$DB_PASSWORD" -h "$DB_HOST" -P 3306 -e "SELECT 1"; do
    echo "Waiting for MySQL to be ready..."
    sleep 2
done

# Initialize the database
mysql -u $DB_USER -p"$DB_PASSWORD" -h "$DB_HOST" -P 3306 -D "$DB_NAME" < /var/www/html/database.sql

# Update the config.php file with database credentials
sed -i "s|\$dbhost = ''|\$dbhost = '$DB_HOST'|; s|\$dbuser = ''|\$dbuser = '$DB_USER'|; s|\$dbpass = ''|\$dbpass = '$DB_PASSWORD'|; s|\$dbname = ''|\$dbname = '$DB_NAME'|" /var/www/html/config.php

systemctl restart apache2

# Start Apache in the foreground
apache2ctl -D FOREGROUND