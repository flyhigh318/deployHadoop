#!/bin/sh
set -eux -o pipefail

ambariRepo=$1
ambariRepoHost=$2
hdpRepo=$3
#set db default env 
ambariRepo=${ambariRepo:-/etc/yum.repos.d/ambari.repo}
ambariRepoHost=${ambariRepoHost:-ambari.hdprepo.com}
hdpRepo=${hdpRepo:-/etc/yum.repos.d/hdp.repo}

function configReop(){
  cat > ${ambariRepo} << EOF
#VERSION_NUMBER=2.7.3.0-139
[ambari-2.7.3.0]
name=ambari Version - ambari-2.7.3.0
baseurl=http://${ambariRepoHost}/ambari/centos7/2.7.3.0-139
gpgcheck=0
gpgkey=http://${ambariRepoHost}/ambari/centos7/2.7.3.0-139/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1
EOF

  cat > ${hdpRepo} << EOF
#VERSION_NUMBER=3.0.0.0-1634
[HDP-3.0]
name=HDP
baseurl=http://${ambariRepoHost}/HDP/centos7/3.0.0.0-1634
gpgcheck=0
gpgkey=http://${ambariRepoHost}/HDP/centos7/3.0.0.0-1634/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1


[HDP-UTILS-1.1.0.22]
name=HDP-UTILS
baseurl=http://${ambariRepoHost}/HDP-UTILS/centos7/1.1.0.22
gpgcheck=0
gpgkey=http://${ambariRepoHost}/HDP-UTILS/centos7/1.1.0.22/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1

[HDP-3.0-GPL]
name=HDP-GPL
baseurl=http://${ambariRepoHost}/HDP-GPL/centos7/3.0.0.0-1634
gpgcheck=0
gpgkey=http://${ambariRepoHost}/HDP-GPL/centos7/3.0.0.0-1634/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1
EOF
}

rm -rf ${ambariRepo} ${hdpRepo}
configReop
yum clean all
yum makecache fast
