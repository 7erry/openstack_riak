#!/bin/bash
set -e -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get upgrade -y

apt-get install -y wget

# add snmp daemon
apt-get install -y snmpd
#sed –i 's/-V systemonly//g' /etc/snmp/snmpd.conf
#sed –i 's/^agentAddress/#agentAddress/g' /etc/snmp/snmpd.conf
#sed -i 's/^#agentAddress udp:161/agentAddress udp:161/g' /etc/snmp/snmpd.conf
#/etc/init.d/snmpd restart

# install as per Basho
wget http://downloads.basho.com.s3-website-us-east-1.amazonaws.com/riak/CURRENT/ubuntu/lucid/riak_1.2.0-1_amd64.deb
apt-get install -y libssl0.9.8
dpkg -i riak_1.2.0-1_amd64.deb

# get our riak config files from cloud.nimbus
sudo wget "https://github.com/7erry/openstack_riak/raw/master/app.config"
sudo wget "https://github.com/7erry/openstack_riak/raw/master/vm.args"
# change the ip address to be that of eth0
echo "/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}' " >~/myip.sh
chmod o+x ~/myip.sh
echo 'perl -p -i -e s/127.0.0.1/$1/g *' >~/rip.sh
chmod o+x ~/rip.sh
~/rip.sh `~/myip.sh`
cat app.config > /etc/riak/app.config
cat vm.args > /etc/riak/vm.args

# start it up
riak start
# wait a second
sleep 15
# join the master node
riak-admin cluster join riak@CHANGEMETOMASTERNODENAME
riak-admin cluster plan
riak-admin cluster commit

# done
