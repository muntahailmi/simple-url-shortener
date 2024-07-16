#!/bin/bash

mv config.sample.php config.php
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

# Set ServerName in Apache configuration
echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Connect and setup database
echo "{DB_PASS} {DB_HOST} {DB_NAME}"

# Wait for MySQL to be ready
until mysql -u admin -p"{DB_PASS}" -h ${DB_HOST}" -P 3306 -e "SELECT 1"; do
    echo "Waiting for MySQL to be ready..."
    sleep 2
done

# Initialize the database
mysql -u admin -p"{DB_PASS}" -h "{DB_HOST}" -P 3306 -D "{DB_NAME}" < /var/www/html/database.sql

# Update the config file
sed -i "s|\$dbhost = '';|\$dbhost = '{DB_HOST}';|; s|\$dbuser = '';|\$dbuser = 'admin';|; s|\$dbpass = '';|\$dbpass = '{DB_PASS}';|; s|\$dbname = '';|\$dbname = '{DB_NAME}';|" /var/www/html/config.php

# Start Apache in the foreground
apache2ctl -D FOREGROUND