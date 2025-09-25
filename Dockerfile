FROM ubuntu:18.04
ENV TZ=America/Denver
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages and enable Apache modules
RUN apt update && \
    apt -y install apache2 php libapache2-mod-php php-mysqli git mysql-client apache2-utils && \
    a2enmod rewrite && \
    a2enmod expires && \
    a2enmod headers

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Clone the repository and configure the application
COPY . /var/www/html
COPY config.sample.php config.php
RUN rm -f index.html && \
    sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

# Create initialization script
RUN echo "#!/bin/bash\n" \
         "echo \"\${DB_USER} \${DB_PASS} \${DB_HOST} \${DB_NAME}\"\n" \
         "until mysql -u \"\${DB_USER}\" -p\"\${DB_PASS}\" -h \"\${DB_HOST}\" -P 3306 -e \"SELECT 1\"; do\n" \
         "  echo \"Waiting for MySQL to be ready...\"\n" \
         "  sleep 2\n" \
         "done\n" \
         "mysql -u \"\${DB_USER}\" -p\"\${DB_PASS}\" -h \"\${DB_HOST}\" -P 3306 -D \"\${DB_NAME}\" < /var/www/html/database.sql\n" \
         "sed -i \"s|\\\$dbhost = '';|\\\$dbhost = '\${DB_HOST}';|; s|\\\$dbuser = '';|\\\$dbuser = '\${DB_USER}';|; s|\\\$dbpass = '';|\\\$dbpass = '\${DB_PASS}';|; s|\\\$dbname = '';|\\\$dbname = '\${DB_NAME}';|\" /var/www/html/config.php\n" \
         "\n" > /init-container.sh
RUN chmod +x /init-container.sh
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Expose port 80
EXPOSE 80

# Run initialization script and then start Apache
CMD ["/bin/bash", "-c", "/startup.sh && apache2ctl -D FOREGROUND"]
