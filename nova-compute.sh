#!/bin/bash

# Settings
. settings

apt-get install -y nova-api nova-compute nova-network python-mysqldb mysql-client curl dnsmasq bridge-utils

# Nova Setup
sed -e "s,999888777666,$SERVICE_TOKEN,g" api-paste-keystone.ini.tmpl > api-paste-keystone.ini

mysql -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS -e 'DROP DATABASE IF EXISTS nova;'
mysql -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS -e 'CREATE DATABASE nova;'

# Nova Config
sed -e "s,%HOST_IP%,$HOST_IP,g" nova.conf.tmpl > nova.conf
sed -e "s,%VLAN_INTERFACE%,$VLAN_INTERFACE,g" -i nova.conf
sed -e "s,%REGION%,$REGION,g" -i nova.conf
sed -e "s,%MYSQL_CONN%,$MYSQL_CONN,g" -i nova.conf

# Fix dnsmasq
sed -e "s,ENABLED=1,ENABLED=0,g" -i /etc/default/dnsmasq

killall dnsmasq
sleep 1
killall -9 dnsmasq

cp nova.conf api-paste-keystone.ini /etc/nova/
chown nova:nova /etc/nova/nova.conf /etc/nova/api-paste-keystone.ini

service nova-api restart
service nova-network restart
service nova-compute restart