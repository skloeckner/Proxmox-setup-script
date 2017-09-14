#!/bin/bash

# PVE No subscription
echo "deb http://download.proxmox.com/debian stretch pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
echo "" > /etc/apt/sources.list.d/pve-enterprise.list

# Setup preferred zfs dataset names
zfs create rpool/KVMStor
zfs create rpool/LXCStor
zfs create rpool/KVMStor/data

# Rsync data to dataset to be replicated
/usr/bin/rsync -r /etc/pve/qemu-server /rpool/KVMStor/data > /dev/null

# Install pre-reqs of zfs snapshot management tools and overall updates
apt-get update && apt-get upgrade -y

apt-get install git libconfig-inifiles-perl sudo lzop mbuffer pv -y

# Get latest version of Sanoid and replication tools and install them
git clone https://github.com/jimsalterjrs/sanoid
cp ./sanoid/sanoid /usr/local/bin/
cp ./sanoid/syncoid /usr/local/bin/
mkdir /etc/sanoid
cp ./sanoid/sanoid.conf /etc/sanoid
cp ./sanoid/sanoid.defaults.conf /etc/sanoid

# Create secondary backup pool in order to replicate datasets to/from
zpool create -f -o ashift=12 backuppool mirror /dev/sdc /dev/sdd

zfs create backuppool/data
