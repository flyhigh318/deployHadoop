#!/bin/bash
# describe: 机器之间做免密, 需根据实际情况更新rda_pub
# server:  cd ./files && nohup python3 -m http.server 12345 & 
# client:  curl -sfL 10.74.101.6:12345/6_init_ssh.sh | bash -


sshFilePath=/etc/ssh/sshd_config
authorziedFile=/root/.ssh/authorized_keys

if grep -q -E '^PermitRootLogin yes' ${sshFilePath};then
   echo "chek root login well"
else
   if grep -q -E '^#PermitRootLogin no' ${sshFilePath};then
     sed -i "s/#PermitRootLogin no/PermitRootLogin yes/g"  ${sshFilePath}
   fi
   if grep -q -E '^#PermitRootLogin yes' ${sshFilePath};then
     sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/g"  ${sshFilePath}
   fi
   if grep -q -E '^PermitRootLogin no' ${sshFilePath};then
     sed -i "s/PermitRootLogin no/PermitRootLogin yes/g"  ${sshFilePath}
   fi
fi
if grep -q -E '^PasswordAuthentication yes' ${sshFilePath};then
   echo "chek PasswordAuthentication well"
else
  if grep -q -E '^PasswordAuthentication no' ${sshFilePath};then
     sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g"  ${sshFilePath}
   fi
fi

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkQTU3zFRMmQMWVsai4/sjn4bYRbn5/H2BLcqDyrHYeGnB91AyS0R82s16pq15KeBoEK7ifD4fVRzPUcIODLCSBwib5luzbVzAroNbUVSZi8haXmi97DUWMr18Ajg1gLtr5JuKAE/yvNJKZiF+lCa1kRITLvb751nr2Y0dsRcfMwRPbwfHWNKYbR21NCPDWk9Me/6xr1qR8FIxq3xNpjpwn2tohjuA+l/2P9cauiGbU/6EoWNYGAuUJO2Ywn9x0wNhyl6X8xazDB9+CIebzG5R3H1BLhxhpsHERBX0o9ShzyBwUVdOuRKBl0ad7OckGvolXrBMRsIUFnp6ZYBDrjTT root@10.74.101.6" >> "${authorziedFile}"
systemctl restart sshd