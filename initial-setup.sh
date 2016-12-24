#!/bin/bash

# PVE No subscription
echo "deb http://download.proxmox.com/debian jessie pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
echo "" > /etc/apt/sources.list.d/pve-enterprise.list

# Setup preferred zfs dataset names
zfs create rpool/KVMStor
zfs create rpool/LXCStor
zfs create rpool/KVMStor/data

# Symbolic link to qemu config file proxmox uses on dataset to be synced to another server(In case of catastrophe)
ln -s /etc/pve/qemu-server /rpool/data

# Install pre-reqs of zfs snapshot management tools and overall updates
apt-get update && apt-get upgrade -y

apt-get install git libconfig-inifiles-perl sudo lzop mbuffer pv -y

# Get latest version of Sanoid and replication tools and install them
git clone https://github.com/jimsalterjrs/sanoid
cp ./sanoid/sanoid /usr/local/bin/
cp ./sanoid/syncoid /usr/local/bin/

# Create secondary backup pool in order to replicate datasets to/from
zpool create -f -o ashift=12 backuppool mirror /dev/sdc /dev/sdd

zfs create backuppool/data
