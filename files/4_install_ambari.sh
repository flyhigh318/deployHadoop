#!/bin/bash
set -eux -o pipefail

databaseDir=$1
mysqlRootPwd=$2
ambariDb=$3
ambariDbPwd=$4
hiveDb=$5
hiveDbPwd=$6

#set db default env 
databaseDir=${databaseDir:-/data/app/mysql}
mysqlRootPwd=${mysqlRootPwd:-"Bigdata-aliyun@2023"}
ambariDb=${ambariDb:-"ambari"}
ambariDbPwd=${ambariDbPwd:-"Bigdata_123"}
hiveDb=${hiveDb:-"hive"}
hiveDbPwd=${hiveDbPwd:-"Hive_123"}

function InstallMysql57() {
  yum localinstall https://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm -y
  yum install mysql-community-server -y --nogpgcheck
  yum install mysql-connector-java -y --nogpgcheck
}
function InstallAmbariServer() {
  yum install ambari-server -y
  yum install expect -y
}
function AmbariSetup() {
  # set hive jdbc driver
  cp /usr/share/java/mysql-connector-java.jar /var/lib/ambari-server/resources/
  ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
}
function MysqlSetup() { 
  [ ! -d "${databaseDir}" ] && mkdir -p "${databaseDir}"
  chown mysql:mysql -R "${databaseDir}"
  cat > /etc/my.cnf << 'CONF'
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/data/app/mysql
socket=/var/lib/mysql/mysql.sock

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
CONF

  # set mysql root password 
  systemctl start mysqld
  sleep 10
  tmpPasswd=$(cat /var/log/mysqld.log \
    | grep -i 'A temporary password is generated for' \
    | awk '{print $NF}')
  mysql --user=root  --connect-expired-password  --password="${tmpPasswd}"  << updatepasswd
    alter user 'root'@'localhost' identified by "${mysqlRootPwd}";
    flush privileges;
updatepasswd
  systemctl restart mysqld
}
function CreateAmbariDatabase() {
  mysql --user="root" --password="${mysqlRootPwd}" << EOF 
    create database ambari default character set utf8;
    grant all on ambari.* to ambari@localhost identified by 'Bigdata_123';
    grant all on ambari.* to ambari@'%' identified by 'Bigdata_123';
    create database hive default character set utf8;
    grant all on hive.* to hive@localhost identified by 'Hive_123';
    grant all on hive.* to hive@'%' identified by 'Hive_123';
EOF
}

InstallMysql57
InstallAmbariServer
AmbariSetup
MysqlSetup
CreateAmbariDatabase