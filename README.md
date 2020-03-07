# Ubuntu 16.04 Vagrant VM: Phalcon 4 + PHP 7.3
![logo](http://i.imgur.com/rKZ8aq9.png)

* Git
* Nginx
* PHP 7.3
* Phalcon 4.0.4
* MySQL 5.7
* Redis
* Composer
* NodeJS
* Npm
* Gulp
* Memcached
* PHPUnit

# Quick install
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://www.vagrantup.com/)
3. Clone this project `git clone https://github.com/uonick/vagrant-php7-phalcon.git`
4. Run on host machine:
    * Linux:
        * `sudo apt-get install dnsmasq`
        * `echo "address=/.dev/192.168.3.3" >> /etc/dnsmasq.conf`
    * macOS:
        * `brew install dnsmasq`
5. Go to directory with README file (`cd vagrant-php7-phalcon`)
6. Run `vagrant up`
7. :tada: :balloon:

# Development
1. Go to `vagrant-php7-phalcon/www/`
2. Make `$directory/public` or `$directory/public/index.php`
3. Add `192.168.3.3 $directory.dev` to `/etc/host` file
    1. For example add `192.168.3.3 hello.dev` and open `hello.dev` in browser
4. Open url `http://$directory.dev/`
5. Enjoy :sunglasses:

# Domains
* `domain.dev`
  * `./www/domain/public/index.php`
* `developer.dev`
  * `./www/developer/public/index.php`

# Subdomain
* `sub.domain.dev`
  * `./www/domain/sub/www/index.php`
* `sub.developer.dev`
  * `./www/developer/sub/www/index.php`
  
# MySQL
* login: `root`
* password: `root`
