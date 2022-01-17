#!/bin/bash
pvcreate /dev/sdb
vgextend vgvagrant /dev/sdb
lvm lvextend -l +100%FREE /dev/vgvagrant/root
resize2fs -p /dev/mapper/vgvagrant-root