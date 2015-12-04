Vagrant.configure("2") do |config|
  config.vm.box = "hadoop"
  config.ssh.insert_key = false

  config.vm.provider :virtualbox do |v|
    v.memory = 8192
    v.cpus = 2
  end

  config.vm.define :hadoop01 do |hadoop01|
    hadoop01.vm.hostname = "hadoop01.ambari.apache.org"
    hadoop01.vm.network :private_network, ip: "192.168.66.101"
  end

  config.vm.define :hadoop02 do |hadoop02|
    hadoop02.vm.hostname = "hadoop02.ambari.apache.org"
    hadoop02.vm.network :private_network, ip: "192.168.66.102"
  end

  config.vm.define :hadoop03 do |hadoop03|
    hadoop03.vm.hostname = "hadoop03.ambari.apache.org"
    hadoop03.vm.network :private_network, ip: "192.168.66.103"
  end

  config.vm.provision :shell do |shell|
    shell.inline = 'cd /vagrant && ./bootstrap.sh'
  end
end
