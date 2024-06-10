#!/bin/bash
set -eux -o pipefail

mysqlServerHost=${mysqlServerHost:-"ambariserver.com"}
dbUser="ambari"
dbPasswd="Bigdata_123"
dbDatabase="ambari"
sqlFile="/var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql"

# ambari ddl mysql create
mysql -h "${mysqlServerHost}" --user="${dbUser}"  --password="${dbPasswd}" "${dbDatabase}" < "${sqlFile}"

