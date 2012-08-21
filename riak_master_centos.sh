#!/bin/bash
set -e -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
export DEBIAN_FRONTEND=noninteractive

yum -y update

# install as per Basho
#wget http://downloads.basho.com/riak/CURRENT/riak-1.1.4-1.el6.x86_64.rpm
#rpm -Uvh riak-1.1.4-1.el6.x86_64.rpm
wget http://downloads.basho.com.s3-website-us-east-1.amazonaws.com/riak/CURRENT/rhel/6/riak-1.2.0-1.el6.x86_64.rpm
rpm -Uvh riak-1.2.0-1.el6.x86_64.rpm

# get perl
yum -y install perl

# get our riak config files from cloud.nimbus
wget "https://github.com/7erry/openstack_riak/raw/master/app.config"
wget "https://github.com/7erry/openstack_riak/raw/master/vm.args"
# change the ip address to be that of eth0
echo "/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}' " >~/myip.sh
chmod o+x ~/myip.sh
echo 'perl -p -i -e s/127.0.0.1/$1/g *' >~/rip.sh
chmod o+x ~/rip.sh
~/rip.sh `~/myip.sh`
cat app.config > /etc/riak/app.config
cat vm.args > /etc/riak/vm.args

sleep 2

# start it up
/usr/sbin/riak start

# done
