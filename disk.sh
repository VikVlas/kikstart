#!/bin/bash
lsblk | grep sd

#MACHINEDEVICE=/dev/sda
#IFSWAPON="Y"
#WINSIZE=14000
# Если размер раздела для корня линукс не указан, он будет выделен до конца диска
#ROOTSIZE=""

# Размер swap вычисляется как удвоенная оперативная память
memsize=$(cat /proc/meminfo | grep MemTotal | while read a size b; do echo $size; done)
SWAPSIZE=$(echo "scale=0; $memsize*2/1000"|bc -l)

echo $memsize
echo $SWAPSIZE