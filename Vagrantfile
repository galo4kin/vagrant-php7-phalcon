# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

    config.vm.box = "ubuntu/trusty32"

    config.vm.box_check_update = true

    config.vm.network :forwarded_port, guest: 80, host: 8080
    config.vm.network :forwarded_port, guest: 3306, host: 3306
    config.vm.network :forwarded_port, guest: 6379, host: 6379

    config.vm.network "private_network", ip: "192.168.3.3"

    config.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--memory", "1548"]
        v.customize ["modifyvm", :id, "--vram", "32"]
      end

    # config.vm.network "public_network"

    config.vm.synced_folder "www/", "/vagrant/www", :mount_options => ["dmode=777", "fmode=666"], :owner => 'www-data', :group => 'www-data'

    config.vm.provision "shell", path: "setup.sh"
end
