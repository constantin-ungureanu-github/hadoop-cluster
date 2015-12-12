# Hadoop HDP cluster on local desktop using Vagrant and VirtualBox.

## Step 1 - Add prerequisites

Install Vagrant 1.7.4 and VirtualBox 5.0.10.

Run on host machine:

> vagrant plugin install vagrant-vbguest

## Step 2 - Add Vagrant box

###Install Oracle Linux 7.2

8 GB RAM

80 GB root partition and swap

160 GB /data partition

2 networks, one NAT (forwarding rule ssh:tcp:[blank]:2222:[blank]:22), one host only

disable audio, usb

### install and connect putty 127.0.0.1:2222 after install

security policy off

infrastructure server

no LVM but standard partitions

XFS filesystem

enable network interfaces

hostname localhost

add root password: vagrant

add user vagrant with password vagrant in group admin


###disable firewall, SELinux, requiretty

> systemctl stop firewalld; systemctl disable firewalld; chkconfig firewalld off

> sed -i 's/^\(Defaults.*requiretty\)/#\1/' /etc/sudoers

> echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

> nano /etc/selinux/config

  SELINUX=disabled

> reboot

###add key

> mkdir -m 0700 -p /root/.ssh

> curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /root/.ssh/authorized_keys

> mkdir -m 0700 -p /home/vagrant/.ssh

> curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys

> chmod 600 /home/vagrant/.ssh/authorized_keys

> chown -R vagrant:vagrant /home/vagrant/.ssh


###update

> yum clean all; yum update -y

> reboot


###install ntp

> yum remove -y chrony; yum install -y ntp ntpdate

> systemctl enable ntpdate; chkconfig ntpdate on; ntpdate pool.ntp.org

> systemctl enable ntpd; systemctl start ntpd; chkconfig ntpd on


###install Vbguest

Insert from Virtualbox the additional tools

> yum install -y gcc make bzip2 kernel-uek-devel-`uname -r`

> mount /dev/cdrom /mnt

> cd /mnt

> ./VBoxLinuxAdditions.run

> reboot


###clean

> yum clean all

> rm -rf /tmp/*

> rm -f /var/log/wtmp /var/log/btmp

> sudo dd if=/dev/zero of=/bigemptyfile bs=4096k

> sudo rm -rf /bigemptyfile

> sudo dd if=/dev/zero of=/data/bigemptyfile bs=4096k

> sudo rm -rf /data/bigemptyfile

> history -c

> rm -f .bash_history

> shutdown -h now


###compact

Run on host machine:

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyhd hadoop.vdi --compact

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyhd data.vdi --compact

The resulted box can be found here: https://drive.google.com/file/d/0B7rIW58QtdfOVjFIUmVqQmQtbjA/view?usp=sharing


###add box

Run on host machine:

> vagrant package --output <path>hadoop.box --base hadoop

> vagrant box add hadoop <path>hadoop.box


## Step 3 - Configure

Configure the Hadoop cluster by editing the Vagrantfile and hosts files. The existing example has 3 nodes.

To add more nodes, simply define more nodes similarly with the existing ones in Vagrantfile, and add their private IPs to the hosts file.

Also can modify the CPUs and memory options. Add the mapping IP-hostname for the desired nodes to the local machine.

In our example with 3 nodes, just add following to C:\Windows\System32\drivers\etc\hosts if using Windows or to /etc/hosts if Linux.

> 192.168.66.101 hadoop01.ambari.apache.org

> 192.168.66.102 hadoop02.ambari.apache.org

> 192.168.66.103 hadoop03.ambari.apache.org

## Step 4 - Create local cluster

Run:

> vagrant up

## Step 5 - Download Ambari.

Current version is 2.1.2.1. The instruction are here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.1.2.1/bk_Installing_HDP_AMB/content/_download_the_ambari_repo_lnx7.html

Run on first node (can use Putty to connect to that node with root/vagrant credentials or run "vagrant ssh hadoop01" to your host console):

> wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.1.2.1/ambari.repo -O /etc/yum.repos.d/ambari.repo

> yum repolist

> yum install ambari-server

## Step 6 - Setup and Install Ambari

The instructions are here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.1.2.1/bk_Installing_HDP_AMB/content/_set_up_the_ambari_server.html

Run on first node:

> ambari-server setup

> ambari-server start

> chkconfig ambari-server on

## Step 7 - Install Hadoop using Ambari

Open your web browser (assuming your first node is hadoop01, where Ambari is installed): http://hadoop01.ambari.apache.org:8080/#/login

Follow the steps described here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.1.2.1/bk_Installing_HDP_AMB/content/ch_Deploy_and_Configure_a_HDP_Cluster.html

To specify the nodes, simply add as following:

> hadoop01.ambari.apache.org

> hadoop02.ambari.apache.org

> hadoop03.ambari.apache.org

To specify the key, use the key file from this repo.

There is a bug with snappy package in Ambari 2.1.2.1 with Oracle Linux, because Oracle Linux has a newer version already installed.

Run on each node:

> yum remove snappy -y; yum install snappy-devel -y

Press retry button.

Have fun!
