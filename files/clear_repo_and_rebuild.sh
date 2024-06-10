#!/bin/bash
# describe: just do it when repo can't work 
rm -rf /etc/yum.repos.d/ambari-hdp-*.repo
yum clean all
yum makecache
