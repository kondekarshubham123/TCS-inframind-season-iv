#!/bin/bash
# Always a good idea to update things
apt-get update -y
# Install the Apache2 server, PHP, and MySQL client.  The rest of the install are modules for WordPress.
apt-get -y install apache2 php libapache2-mod-php php-common php-mysql php-gmp php-curl php-intl php-mbstring php-xmlrpc php-gd php-xml php-cli php-zip mysql-client
# Download, unpack and move, the latest WordPress release.
wget https://wordpress.org/latest.tar.gz
tar -zxf latest.tar.gz
cd wordpress
cp -r . /var/www/html
cd /var/www/html
rm index.html
# Allow apache2 to change the wp-config.php file
chgrp www-data .
chmod g+w . 