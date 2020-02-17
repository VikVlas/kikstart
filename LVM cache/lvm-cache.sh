#!/bin/bash
lsblk

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

yum -y update