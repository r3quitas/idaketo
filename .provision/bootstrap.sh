#!/usr/bin/env bash

#CONFIG START

#MySQL database connection data
MYSQL_USER="idaketo"
MYSQL_PASS="kldsfIiowejq932"
MYSQL_NAME="idaketo"

#CONFIG END

#Update apt-get
apt-get update

#Prepare MySQL installation
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

#Install MySQL
apt-get install -y mysql-server

echo "DROP DATABASE IF EXISTS $MYSQL_NAME" | mysql -uroot -proot
echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASS'" | mysql -uroot -proot
echo "CREATE DATABASE $MYSQL_NAME" | mysql -uroot -proot
echo "CREATE DATABASE test_$MYSQL_NAME" | mysql -uroot -proot
echo "GRANT ALL ON $MYSQL_NAME.* TO '$MYSQL_USER'@'%'" | mysql -uroot -proot
echo "GRANT ALL ON test_$MYSQL_NAME.* TO '$MYSQL_USER'@'%'" | mysql -uroot -proot
echo "FLUSH PRIVILEGES" | mysql -uroot -proot
mysql -u${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_NAME} < /vagrant/database.sql

# Set MySql to listen to connections from anywhere.
# Since the vagrant is only reachable from its host, this is of no negative consequence.
sed -i "s/bind-address/#bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf

 # Restart MySql
service mysql restart

# Install Apache
apt-get install -y apache2

# Set Apache DocumentRoot to /var/www instead of /var/www/html
sed -i "s#DocumentRoot /var/www/html#DocumentRoot /var/www#g" /etc/apache2/sites-available/000-default.conf

# Enable Apache AllowOverride globally
sed -i "s#AllowOverride None#AllowOverride All#g" /etc/apache2/apache2.conf

# Enable mod-rewrite
sudo a2enmod rewrite

# Restart Apache for configuration to apply
service apache2 restart

# Link /vagrant/src to /var/www
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant/idaketo /var/www
fi

# Install PHP
apt-get install -y php
apt-get install -y php-dev
apt-get install -y php-mysql
apt-get install -y php-mysqli
apt-get install -y libapache2-mod-php
apt-get install -y php-intl
apt-get install -y php-mbstring
apt-get install -y php-soap
apt-get install -y php-pdo-sqlite
apt-get install -y php-gd
apt-get install -y php-xsl

# Restart Apache
service apache2 restart

# Download and install zip and unzip
apt-get install -y zip
apt-get install -y unzip