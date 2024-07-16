#!/bin/bash

# Set timezone and noninteractive mode
export TZ=America/Denver
export DEBIAN_FRONTEND=noninteractive

# Update package list and install required packages
apt update
apt -y install apache2 php libapache2-mod-php php-mysqli git mysql-client apache2-utils

# Enable Apache modules
a2enmod rewrite
a2enmod expires
a2enmod headers

# Set the working directory to /var/www/html
cd /var/www/html

# Clone the repository and configure the application
rm -f index.html