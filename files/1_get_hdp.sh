#!/bin/sh
set -eux -o pipefail

hdpDir=$1
jdkDir=$2
#set db default env
hdpDir=${hdpDir:-/var/www/html/hadoop}
jdkDir=${jdkDir:-/data/app}

function installCos() {
    cat > /tmp/cosTest.sh << 'install'
#!/bin/bash
# used for configuring tencent cos access 
wget https://cosbrowser.cloud.tencent.com/software/coscli/coscli-linux -O /usr/local/bin/coscli
chmod 755 /usr/local/bin/coscli
cat > /root/.cos.yaml << EOF
cos:
  base:
    secretid: yourSecretId
    secretkey: yourSecretkey
    sessiontoken:
    protocol: https
  buckets:
  - name: devops-storage-1304425759
    alias: devops-storage-1304425759
    region: ap-beijing
EOF
coscli ls cos://devops-storage-1304425759/
if [ $?==0 ]
then
  echo "tencent cos config success"
else
  echo "tencent cos config error"
fi
install
}

function downloadHdpJdk() {
  [ -d ${hdpDir} ] || mkdir -p ${hdpDir}
  cd ${hdpDir}
  coscli sync cos://devops-storage-1304425759/bigdata/hdp_repos.tar.gz ./hdp_repos.tar.gz
  
  [ -d ${jdkDir} ] || mkdir -p ${jdkDir}
  cd ${jdkDir}
  coscli sync cos://devops-storage-1304425759/bigdata/jdk/amd64/jdk1.8.0_311.tar.gz  ./jdk1.8.0_311.tar.gz
}

function unzipHdpJdk() {
    tar -zxvf ${hdpDir}/hdp_repos.tar.gz -C ${hdpDir}
    mv ${hdpDir}/hdp_repos/hdp/HDP-UTILS/HDP-UTILS ${hdpDir}
    mv ${hdpDir}/hdp_repos/hdp/HDP ${hdpDir}
    mv ${hdpDir}/hdp_repos/hdp/HDP-GPL ${hdpDir}
    mv ${hdpDir}/hdp_repos/ambari ${hdpDir}
    rm -rf ${hdpDir}/hdp_repos
    tar -zxvf ${jdkDir}/jdk1.8.0_311.tar.gz -C ${jdkDir}
}


installCos
[ -f '/tmp/cosTest.sh' ] && bash /tmp/cosTest.sh && rm -rf /tmp/cosTest.sh
downloadHdpJdk
unzipHdpJdk


