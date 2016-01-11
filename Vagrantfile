# -*- mode: ruby -*-cd  .
# vi: set ft=ruby :
Vagrant.configure(2) do |config|

config.vm.box = "ubuntu/trusty64"

config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.define 'dev-box' do |node|
    node.vm.hostname = 'pma.local'
    node.hostmanager.aliases = %w(test.local sandelis.local)
end

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
config.vm.network "private_network", ip: "33.33.33.33"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
config.vm.synced_folder "../test", "/home/vagrant/public_html/test.local"
config.vm.synced_folder "../public_html/sandelis", "/home/vagrant/public_html/sandelis.local"

   config.vm.provider "virtualbox" do |vb|
  #   	# Display the VirtualBox GUI when booting the machine
  #   	vb.gui = true
  #
  #   	# Customize the amount of memory on the VM:
    	vb.memory = "1024"
   end

  config.vm.provision :shell, path: "bootstrap.sh"
end
