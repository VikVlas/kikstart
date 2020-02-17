#!/bin/bash

mkfs.ext4  /dev/sdc1
pvcreate /dev/sdb4 /dev/sdc1

vgcreate vg0 /dev/sdc1
lvcreate -n lv_jenkins -L 500G data /dev/sdc1
mkfs.ext4  /dev/vg0/lv_jenkins
vgextend vg0 /dev/sdb4
lvcreate -n lv_cache_meta -L 1G  vg0 /dev/sdb4
lvcreate -L 50G -n lv_cache vg0 /dev/sdd4
lvconvert --type cache-pool  --cachemode writeback --poolmetadata vg0/lv_cache_meta vg0/lv_cache
lvconvert --type cache --cachepool vg0/lv_cache vg0/lv_jenkins

dnf update -y
dnf install java -y



#======= adduser jenkins =======



sudo useradd jenkins
sudo usermod -md /jenkins jenkins
su jenkins

echo "xxxxxxxxx" cat >> ~./ssh/autorized.key

# ====== install jenkins =======
 cd /usr/local/src && wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
  rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
  yum install jenkins -y
  service jenkins start
  chkconfig jenkins on
  sudo echo StrictHostKeyChecking no >> cat 01-jenkins.conf

# ========= install soft ======
dnf install chrony postfix smartmontools -y

# =========
sudo $UUID=blkid | grep /dev/mapper/vg0-lv_jenkins | cut -d ' ' -f2
sudo mount/dev/mapper/vg0-lv_jenkins /jenkins/
sudo echo '$UUID /jenkins ext4 defaults 1 2' >> cat /etc/fstab 

