#!/bin/bash
# Using Ubuntu

sudo echo "127.0.1.1 ubuntu-xenial" >> /etc/hosts

#
# Install
#
echo -e "----------------------------------------"
echo -e "============    BEGIN SETUP   ============="
sudo apt-get update > /dev/null
sudo apt-get install -y language-pack-ru-base language-pack-ru build-essential python-software-properties software-properties-common re2c libpcre3-dev gcc make > /dev/null

#
# Install Git and Tools
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> Git"
sudo apt-get install -y git  > /dev/null

echo -e "----------------------------------------"
echo -e "VAGRANT ==> Tools (mc, htop, unzip etc...)"
sudo apt-get install -y mc htop unzip grc gcc make libpcre3 libpcre3-dev lsb-core autoconf > /dev/null

#
# Install Nginx
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> Nginx"
sudo apt-get install -y nginx  > /dev/null

#
# Nginx host
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> Setup Nginx"
sudo rm -rf /etc/nginx/sites-available/default
sudo rm -rf /etc/nginx/sites-enabled/default
cd ~
# shellcheck disable=SC2016
echo 'server {
    index    index.php index.html index.htm;
    set      $basepath "/vagrant/www";
    set      $domain $host;
    charset  utf-8;

    # check one name domain for simple application
    if ($domain ~ "^(.[^.]*)\.dev$") {
        set $domain $1;
        set $rootpath "${domain}/public/";
        set $servername "${domain}.dev";
    }

    # check multi name domain to multi application
    if ($domain ~ "^(.*)\.(.[^.]*)\.dev$") {
        set $subdomain $1;
        set $domain $2;
        set $rootpath "${domain}/${subdomain}/www/";
        set $servername "${subdomain}.${domain}.dev";
    }

    server_name $servername;

    access_log "/var/log/nginx/server.${servername}.access.log";
    error_log "/var/log/nginx/server.dev.error.log";

    root $basepath/$rootpath;

    # check file exist and send request sting to index.php
    location / {
        try_files $uri $uri/ /index.php?_url=$uri&$args;
    }

    # allow execute all php files
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;

        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index /index.php;

        include fastcgi_params;
        fastcgi_split_path_info       ^(.+\.php)(/.+)$;
        fastcgi_param PATH_INFO       $fastcgi_path_info;
        fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    # turn off cache
    location ~* ^.+\.(js|css)$ {
        expires -1;
        sendfile off;
    }

    # disallow access to apache configs
    location ~ /\.ht {
        deny all;
    }

    # disallow access to git configs path
    location ~ /\.git {
        deny all;
    }
}' > devhosts

#
# Enable host
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> /etc/nginx/sites-available/devhosts"
sudo mv ~/devhosts /etc/nginx/sites-available/devhosts
sudo ln -s /etc/nginx/sites-available/devhosts /etc/nginx/sites-enabled/devhosts
sudo service nginx restart

#
# PHP 7.3
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> PHP 7.3"
sudo add-apt-repository -y ppa:ondrej/php  > /dev/null
sudo apt-get update > /dev/null
sudo apt-get install -y php7.3-fpm php7.3-cli php7.3-common php7.3-json php7.3-opcache php7.3-mysql php7.3-phpdbg php7.3-mbstring php7.3-gd php-imagick  php7.3-pgsql php7.3-pspell php7.3-recode php7.3-tidy php7.3-dev php7.3-intl php7.3-gd php7.3-curl php7.3-zip php7.3-xml php-memcached mcrypt memcached phpunit > /dev/null

#
# PHP Errors
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> Setup PHP 7.3"
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/display_startup_errors = Off/display_startup_errors = On/' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/listen =/listen = 127.0.0.1:9000 ;/' /etc/php/7.3/fpm/pool.d/www.conf
sudo service php7.3-fpm restart

#
# Ccomposer
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> Composer"
curl -sS https://getcomposer.org/installer | php > /dev/null
sudo mv composer.phar /usr/local/bin/composer

#
# Frontend Tools (npm, nodejs, gulp)
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> Frontend Tools (npm, nodejs, gulp)"
curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash - > /dev/null
sudo apt-get install -y nodejs > /dev/null
sudo npm i --global gulp-cli gulp > /dev/null

#
# Redis
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> Redis Server"
sudo apt-get install -y redis-server redis-tools  > /dev/null
sudo cp /etc/redis/redis.conf /etc/redis/redis.bkup.conf
sudo sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf


echo -e "----------------------------------------"
echo -e "VAGRANT ==> PHP Redis"
git clone https://github.com/phpredis/phpredis.git
cd phpredis
git checkout tags/5.2.0/dev/null
phpize
./configure
sudo make && sudo make install > /dev/null
cd ..
rm -rf phpredis
cd ~/
echo "extension=redis.so" > ~/redis.ini
sudo mv ~/redis.ini /etc/php/7.3/mods-available/redis.ini
sudo ln -s /etc/php/7.3/mods-available/redis.ini /etc/php/7.3/fpm/conf.d/20-redis.ini

echo -e "----------------------------------------"
echo -e "VAGRANT ==> Restart Redis & PHP"
sudo service redis-server restart
sudo service php7.3-fpm restart

#
# MySQL 5.7
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> MySQL 5.7"
sudo apt-get install -y debconf-utils -y > /dev/null
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get install -y mysql-server-5.7 mysql-client-5.7 > /dev/null
sudo sed -i 's/bind-address/bind-address = 0.0.0.0#/' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sudo service mysql restart

#
# Phalcon PHP Framework 4
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> Setup Phalcon Framework 4"
cd ~/
curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | sudo bash > /dev/null
sudo apt-get update > /dev/null
sudo apt-get install -y php-psr php7.3-phalcon
#sudo echo 'extension=psr.so' > /etc/php/7.3/mods-available/psr.ini
#sudo echo 'extension=phalcon.so' > /etc/php/7.3/mods-available/phalcon.ini
sudo ln -s /etc/php/7.3/mods-available/psr.ini /etc/php/7.3/fpm/conf.d/19-psr.ini
sudo ln -s /etc/php/7.3/mods-available/phalcon.ini /etc/php/7.3/fpm/conf.d/20-phalcon.ini

#
# Reload servers
#
echo -e "----------------------------------------"
echo -e "VAGRANT ==> Restart Nginx & PHP-FPM"
sudo service nginx restart
sudo service php7.3-fpm restart

#
# Add user to group
#
sudo usermod -a -G www-data vagrant

#
# Complete
#
echo -e "----------------------------------------"
echo -e "======>  VIRTUAL MACHINE READY"
echo -e "======>  TYPE 'vagrant ssh' and be happy!"
echo -e "----------------------------------------"
