Hadoop HDP cluster on local desktop using Vagrant and VirtualBox.

Step 1 - Add prerequisites
Install Vagrant 1.7.4 and VirtualBox 5.0.10.
Download prebuilt Vagrant box containing Oracle Linux 7.2 image from https://drive.google.com/open?id=0B7rIW58QtdfOdXVzVjFMT3FrYVk

Step 2 - Add Vagrant box and Vagrant plugins
Add the downloaded box to Vagrant boxes, and install the VirtualBox Vagrant plugin.
Run:
vagrant box add hadoop <path>hadoop.box
vagrant plugin install vagrant-vbguest

Step 3 - Configure
Configure the hadoop cluster by editing the Vagrantfile and hosts files.
The existing example has a 3 nodes. If want to add more nodes, simply define more nodes similarly with the existing ones in Vagrantfile,
and add their private IPs to the hosts file. Also can modify the CPUs and memory options.

Add the mapping IP-hostname for the desired nodes to the local machine.
In our example with 3 nodes, just add following to C:\Windows\System32\drivers\etc\hosts if using Windows or to /etc/hosts if Linux.
192.168.66.101 hadoop01.ambari.apache.org
192.168.66.102 hadoop02.ambari.apache.org
192.168.66.103 hadoop03.ambari.apache.org

Step 4 - Create local cluster
Run:
vagrant up

Step 5 - Download Ambari.
Current version is 2.1.2.1.
The instruction are here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.1.2.1/bk_Installing_HDP_AMB/content/_download_the_ambari_repo_lnx7.html

Run on first node (can use Putty to connect to that node with root/vagrant credentials or run "vagrant ssh hadoop01" to your host console):
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.1.2.1/ambari.repo -O /etc/yum.repos.d/ambari.repo
yum repolist
yum install ambari-server

There is a bug with snappy package in Ambari 2.1.2.1 with Oracle Linux, because Oracle Linux has a newer version already installed.
If that bug is fixed can remove "yum remove snappy -y" from bootstrap.sh

Step 6 - Setup and Install Ambari
The instructions are here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.1.2.1/bk_Installing_HDP_AMB/content/_set_up_the_ambari_server.html

Run on first node:
ambari-server setup
ambari-server start

Step 7 - Install Hadoop using Ambari
Open your web browser (assuming your first node is hadoop01, where Ambari is installed): http://hadoop01.ambari.apache.org:8080/#/login
Follow the steps described here: http://docs.hortonworks.com/HDPDocuments/Ambari-2.1.2.1/bk_Installing_HDP_AMB/content/ch_Deploy_and_Configure_a_HDP_Cluster.html

When asking for the key, use the insecure_private_key in this repo.

To specify the nodes, simply add as following:
hadoop01.ambari.apache.org
hadoop02.ambari.apache.org
hadoop03.ambari.apache.org

Have fun!
