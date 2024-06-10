#!/bin/bash

dirs=(
    /etc/ambari-agent
    /etc/ambari-metrics-monitor
    /usr/hdp
    /etc/hadoop/
    /etc/hive/
    /var/log/ambari-agent/
    /hadoop/
    /data
    /data1
    /data2
    /data3
)

for dir in ${dirs[@]}
do
   [ ! -d "$dir" ]  && continue
   rm -rf dir
done