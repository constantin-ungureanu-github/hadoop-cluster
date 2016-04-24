# Hadoop HDP cluster on local desktop using Vagrant and VirtualBox.

## Step 1 - Add prerequisites

Install latest Vagrant (with dependencies) and VirtualBox (with extension pack).

If installing on Windows, make sure Microsoft Visual C++ 2010 SP1 Redistributable Package is installed:

https://www.microsoft.com/en-us/download/details.aspx?id=8328

https://www.microsoft.com/en-us/download/details.aspx?id=13523

Run on host machine:

> vagrant plugin install vagrant-vbguest


## Step 2 - Add Vagrant box

###Install CentOS 7 / Oracle Linux 7.2

2 CPUs

8 GB RAM

80 GB root.vdi, / root(64G) and swap (16G) partitions

160 GB data.vdi, /data partition (160)

2 networks, one NAT (forwarding rule ssh:tcp:[blank]:2222:[blank]:22), one host only

disable audio

### install Linux

security policy off

infrastructure server or minimal

no LVM but standard partitions

XFS filesystem

check automatically connect network interfaces, can disable IPV6

hostname localhost

add root password: vagrant

add user vagrant with password vagrant in group admin

### connect with putty 127.0.0.1:2222 root / vagrant

### update

> yum clean all

> yum update -y

> reboot

### disable firewall, SELinux, requiretty

> systemctl stop firewalld; systemctl disable firewalld; chkconfig firewalld off

> sed -i 's/^\(Defaults.*requiretty\)/#\1/' /etc/sudoers

> echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

> vi /etc/selinux/config

  SELINUX=disabled

> reboot

### add key

> mkdir -m 0700 -p /root/.ssh

> curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /root/.ssh/authorized_keys

> mkdir -m 0700 -p /home/vagrant/.ssh

> curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys

> chmod 600 /home/vagrant/.ssh/authorized_keys

> chown -R vagrant:vagrant /home/vagrant/.ssh


### install ntp

> yum remove -y chrony; yum install -y ntp ntpdate

> systemctl enable ntpdate; chkconfig ntpdate on; ntpdate pool.ntp.org

> systemctl enable ntpd; systemctl start ntpd; chkconfig ntpd on


### install Virtualbox extensions dependencies

> yum clean all 

> yum update

For Oracle Linux:

> yum install -y gcc make bzip2 kernel-uek-devel-`uname -r`

For CentOS:

> yum install -y gcc make bzip2 kernel-devel-`uname -r`

### install Virtualbox extensions 

Insert from Virtualbox the additional tools (Devices -> Insert Guest Additions CD image).

> mount /dev/cdrom /mnt

> cd /mnt

> ./VBoxLinuxAdditions.run

> reboot


### clean

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

### compact

Run on host machine:

> cd [Path to VM]

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyhd root.vdi --compact

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyhd data.vdi --compact

### add box

Run on host machine:

> vagrant package --output hadoop.box --base hadoop

> vagrant box add hadoop hadoop.box


## Step 3 - Configure

Configure the Hadoop cluster by editing the Vagrantfile and hosts files. The existing example has 3 nodes.

To add more nodes, simply define more nodes similarly with the existing ones in Vagrantfile, and add their private IPs to the hosts file.

Also can modify the CPUs and memory options. Add the mapping IP-hostname for the desired nodes to the local machine.

In our example with 3 nodes, just add following to C:\Windows\System32\drivers\etc\hosts if using Windows or to /etc/hosts if Linux.

> 192.168.66.101 hadoop01.ambari.apache.org

> 192.168.66.102 hadoop02.ambari.apache.org

> 192.168.66.103 hadoop03.ambari.apache.org


## Step 4 - Create local cluster

From the current folder with the Vagrant file run:

> vagrant up


## Step 5 - Download Ambari.

Current version is 2.2.1.1. The instruction are here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.2.1.1/bk_Installing_HDP_AMB/content/_download_the_ambari_repo_lnx7.html

Run on first node (can use Putty to connect to that node 192.168.66.101:22 with root/vagrant credentials or run "vagrant ssh hadoop01" to your host console):

> wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.1.1/ambari.repo -O /etc/yum.repos.d/ambari.repo

> yum repolist

> yum install ambari-server


## Step 6 - Setup and Install Ambari

The instructions are here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.2.1.1/bk_Installing_HDP_AMB/content/_set_up_the_ambari_server.html

Run on first node:

> ambari-server setup

> ambari-server start


## Step 7 - Install Hadoop using Ambari

Open your web browser (assuming your first node is hadoop01, where Ambari is installed): http://hadoop01.ambari.apache.org:8080/#/login

Follow the steps described here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.2.1.1/bk_Installing_HDP_AMB/content/ch_Deploy_and_Configure_a_HDP_Cluster.html

To specify the nodes, simply add as following:

> hadoop01.ambari.apache.org

> hadoop02.ambari.apache.org

> hadoop03.ambari.apache.org

To specify the key, use the key file from this repo.

There is a bug with snappy package in Ambari with Oracle Linux, because Oracle Linux has a newer version already installed.

If that happens, let it fail on all the nodes, and then run on each node:

> yum remove snappy -y; yum install snappy-devel -y

Go back to web page and press retry button. Now it should work.

Have fun!