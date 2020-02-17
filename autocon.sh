#!/bin/bash

# CONSTANTS
SSH_KEY=111111
# SDB_SIZE=5000
lsblk
#SDA_SIZE=$(lsblk -b|grep disk| grep sda | awk '{print $4}')
#SDA1_SIZE=$(lsblk -b|grep sda1 | awk '{print $4}')
#SDA2_SIZE=$(lsblk -b|grep sda2 | awk '{print $4}')
#SDA3_SIZE=$(lsblk -b|grep sda3 | awk '{print $4}')
#FREE_SIZE=$((SDA_SIZE-(SDA1_SIZE+SDA2_SIZE+SDA3_SIZE)))

#SDB_SIZE=$(lsblk -b|grep disk| grep sdb | awk '{print $4}')

mkfs.ext4  /dev/sda4

mkfs.ext4  /dev/sdb1
pvcreate /dev/sda4 /dev/sdb1

vgcreate vg0 /dev/sdc1
lvcreate -n lv_jenkins -L 500G data /dev/sdc1
mkfs.ext4  /dev/vg0/lv_jenkins
vgextend vg0 /dev/sdb4
lvcreate -n lv_cache_meta -L 1G  vg0 /dev/sdb4
lvcreate -L 50G -n lv_cache vg0 /dev/sdd4
lvconvert --type cache-pool  --cachemode writeback --poolmetadata vg0/lv_cache_meta vg0/lv_cache
lvconvert --type cache --cachepool vg0/lv_cache vg0/lv_jenkins

sudo UUID=$(blkid | grep /dev/mapper/vg0-lv_jenkins | cut -d ' ' -f2)
sudo mount/dev/mapper/vg0-lv_jenkins /jenkins/
sudo echo '$UUID /jenkins ext4 defaults 0 0' >> cat /etc/fstab 

repo-epel
dnf update -y

dnf install java chrony postfix smartmontools -y

systectl start chrony
systectl enabled chrony
systectl start postfix
systectl enabled postfix
systectl start smartmontools
systectl enabled smartmontools
aleases

dnf update -y


#======= adduser jenkins =======
useradd jenkins
# !!!! passwd jenkins
usermod -md /jenkins jenkins
usermod -aG wheel jenkins
su jenkins
cd ~/
sudo mkdir .ssh 
echo "xxxxxxxxx" >> ~./ssh/autorized.key

# ====== install jenkins =======
 cd /usr/local/src && wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
 sudo dnf update -y
  rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
 sudo dnf install jenkins -y
 sudo systectl start jenkins
 sudo chkconfig jenkins on
 sudo echo StrictHostKeyChecking no >> cat 01-jenkins.conf



# =========


