# Hadoop HDP cluster on local machine using Vagrant and VirtualBox.

## Step 1 - Add prerequisites

Install latest Vagrant (with dependencies) and VirtualBox (with extension pack).

For Windows sure Microsoft Visual C++ 2010 SP1 Redistributable Package is installed:

https://www.microsoft.com/en-us/download/details.aspx?id=8328

https://www.microsoft.com/en-us/download/details.aspx?id=13523

Run on host machine:

> vagrant plugin install vagrant-vbguest

## Step 2 - Add Vagrant box

### Add VirtualBox VM

2 CPUs

8 GB RAM

80 GB root.vdi, root(64G) and swap (16G) partitions

160 GB data.vdi, data partition (160)

2 networks, one NAT (forwarding rule ssh:tcp:[blank]:2222:[blank]:22), one host only

disable audio

### Install CentOS 7 minimal

security policy off

minimal configuration

no LVM but standard partitions

XFS filesystem

automatically connect network interfaces, disable IPV6

network 1 Automatic (DHCP)

network 2 Automatic (DHCP) addresses only

hostname localhost

add root password: vagrant

add user vagrant with password vagrant in group admin

### Connect with Putty

127.0.0.1:2222 root / vagrant

### Update

> yum clean all

> yum update -y

> reboot

### Disable NetworkManager, firewall, SELinux, requiretty

> systemctl stop firewalld; systemctl disable firewalld; chkconfig firewalld off

> systemctl stop NetworkManager; systemctl disable NetworkManager; chkconfig NetworkManager off

> chkconfig network on; systemctl enable network; systemctl start network

> sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

> sed -i 's/^\\(Defaults.*requiretty\\)/#\\1/' /etc/sudoers

> echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

> yum remove NetworkManager -y

> reboot

### Add key

> mkdir -m 0700 -p /root/.ssh

> curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /root/.ssh/authorized_keys

> mkdir -m 0700 -p /home/vagrant/.ssh

> curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys

> chmod 600 /home/vagrant/.ssh/authorized_keys

> chown -R vagrant:vagrant /home/vagrant/.ssh

### Install NTP

> yum install -y ntp ntpdate

> systemctl enable ntpdate; chkconfig ntpdate on; ntpdate pool.ntp.org

> systemctl enable ntpd; systemctl start ntpd; chkconfig ntpd on

### Install Virtualbox extensions dependencies

> yum clean all 

> yum update

> yum install -y wget gcc make bzip2 kernel-devel-\`uname -r\`

### Install Virtualbox extensions 

Insert from Virtualbox the additional tools (Devices -> Insert Guest Additions CD image).

> mount /dev/cdrom /mnt

> cd /mnt

> ./VBoxLinuxAdditions.run

> reboot

### Clean

> yum clean all

> rm -rf /tmp/*

> rm -f /var/log/wtmp /var/log/btmp

> dd if=/dev/zero of=/bigemptyfile bs=4096k

> rm -rf /bigemptyfile

> dd if=/dev/zero of=/data/bigemptyfile bs=4096k

> rm -rf /data/bigemptyfile

> history -c

> rm -f .bash_history

> shutdown -h now

### Compact

Run on host machine:

> cd [Path to VM]

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyhd root.vdi --compact

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyhd data.vdi --compact

### Add the box to Vagrant

Run on host machine:

> vagrant package --output hadoop.box --base hadoop

> vagrant box add hadoop hadoop.box

## Step 3 - Configure

Configure the Hadoop cluster by editing the Vagrantfile and hosts files. The existing example has 3 nodes.

To add more nodes, simply define more nodes similarly with the existing ones in Vagrantfile, and add their private IPs to the hosts file.

Also can modify the CPUs and memory options. Add the mapping IP-hostname for the desired nodes to the local machine.

For example, with 3 nodes, just add following to C:\Windows\System32\drivers\etc\hosts if using Windows or to /etc/hosts if Linux.

> 192.168.66.101 hadoop01.ambari.apache.org

> 192.168.66.102 hadoop02.ambari.apache.org

> 192.168.66.103 hadoop03.ambari.apache.org

## Step 4 - Create local cluster

From the current folder with the Vagrant file run:

> vagrant up

## Step 5 - Download Ambari

Current version is 2.2.2.0. The instruction are here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.2.2.0/bk_Installing_HDP_AMB/content/_download_the_ambari_repo_lnx7.html

Run on first node (can use Putty to connect to that node 192.168.66.101:22 with root/vagrant credentials or run "vagrant ssh hadoop01" to your host console):

> wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.2.0/ambari.repo -O /etc/yum.repos.d/ambari.repo

> yum repolist

> yum install ambari-server

## Step 6 - Setup and Install Ambari

The instructions are here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.2.2.0/bk_Installing_HDP_AMB/content/_set_up_the_ambari_server.html

Run on first node:

> ambari-server setup

> ambari-server start

## Step 7 - Install Hadoop using Ambari

Open your web browser (assuming your first node is hadoop01, where Ambari is installed): http://hadoop01.ambari.apache.org:8080/#/login

Follow the steps described here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.2.2.0/bk_Installing_HDP_AMB/content/ch_Deploy_and_Configure_a_HDP_Cluster.html

To specify the nodes, simply add as following:

> hadoop01.ambari.apache.org

> hadoop02.ambari.apache.org

> hadoop03.ambari.apache.org

To specify the key, use the insecure_private_key file from this repo (the Vagrant insecure key).

### Errors

* If the Ambari fails, keep hitting retry. There're some issues with the repos for CentOS.