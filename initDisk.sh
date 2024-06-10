#!/bin/bash

diskNum=9
deviceString=$(echo vd{c..j})


function createDir() {
    for i in $(seq 1 ${diskNum})
    do
      [ -d /data${i} ] || mkdir -p /data${i}
    done
}

function formatXfs() {
    for disk in ${deviceString}
    do 
      echo "process is doing /dev/${disk}"
      mkfs.xfs -f ${disk}
    done
}

function  configFstab() {
    pointer=0
    for disk in ${deviceString}
    do 
      pointer=$[ $pointer + 1 ] 
      echo "process is doing /dev/${disk}"
      uuid=$(blkid -o list /dev/${disk} | awk '$2~/xfs/{print $NF}')
      echo "UUID=${uuid} /data${pointer}                   xfs     defaults,noatime,uquota,prjquota 0 0" >> /etc/fstab
    done   
} 

createDir
formatXfs
configFstab
mount -a