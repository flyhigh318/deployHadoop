#!/bin/bash
set -eux -o pipefail

#mysqlServerHost=10.74.101.29
mysqlServerHost=${mysqlServerHost:-"ambariserver.com"}
dbUser="ambari"
dbPasswd="Bigdata_123"
dbDatabase="ambari"
dbTable=repo_definition

function generateSqlFile() {
  # to do it before runing ambari setup,need to root authorize by dba
  # notice： There can be no spaces after EOF.
  cat >/tmp/createDatabaseAmbari.sql << 'EOF'
    create database ambari default character set utf8;
    grant all on ambari.* to ambari@localhost identified by 'Bigdata_123';
    grant all on ambari.* to ambari@'%' identified by 'Bigdata_123';
    create database hive default character set utf8;
    grant all on hive.* to hive@localhost identified by 'Hive_123';
    grant all on hive.* to hive@'%' identified by 'Hive_123';
EOF
  # if ambari repo doesn't work,please check it. 
  cat >/tmp/updateAmbariRepoDefinition.sql << EOF
    use ${dbDatabase};
    update repo_definition set base_url="http://ambari.hdprepo.com/HDP/centos7/3.0.0.0-1634" where id=25;
    update repo_definition set base_url="http://ambari.hdprepo.com/HDP-UTILS/centos7/1.1.0.22" where id=26;
EOF
}

[ $# -ne 1 ] && echo "Usge: $0 [query|update]" 
generateSqlFile
if [ x"$1" == x"query" ];then
  # only query
  mysql -h "${mysqlServerHost}" --user="${dbUser}"  --password="${dbPasswd}" "${dbDatabase}" << EOF
  use ${dbDatabase};
  select * from  repo_definition;
EOF
elif [ x"$1" == x"update" ];then
  mysql -h "${mysqlServerHost}" --user="${dbUser}"  --password="${dbPasswd}" "${dbDatabase}" < /tmp/updateAmbariRepoDefinition.sql
else
  echo "Usge: $0 [query|update]"  
fi

