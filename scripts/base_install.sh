#!/bin/bash -v

set -e

export roles="$roles$"

cat >> /etc/hosts <<EOF
$master_ip$ saltmaster salt
EOF

export DEBIAN_FRONTEND=noninteractive
wget -O install_salt.sh https://bootstrap.saltstack.com
sh install_salt.sh -D -U stable 2015.8.10
hostname=`hostname` && echo "id: $hostname" > /etc/salt/minion && unset hostname
echo "log_level: debug" >> /etc/salt/minion
echo "log_level_logfile: debug" >> /etc/salt/minion

a="roles:\n";for i in $roles; do a="$a  - $i\n";done;echo $a
cat > /etc/salt/grains <<EOF
pnda:
  flavor: $flavor$
pnda_cluster: $pnda_cluster$
EOF

if [ "x$cloudera_role$" != "x" ]; then
  cat >> /etc/salt/grains <<EOF
  cloudera:
    role: $cloudera_role$
  EOF
fi

cat >> /etc/salt/grains <<EOF
`printf "%b" "$a"`
EOF

service salt-minion restart

if [ -b $volume_dev$ ]; then
  apt-get -y install xfsprogs
  mkfs.xfs $volume_dev$
  mkdir -p /var/log/pnda
  cat >> /etc/fstab <<EOF
  $volume_dev$  /var/log/pnda xfs defaults  0 0
  EOF
  mount -a
fi

DISKS="vdb"
DISK_IDX=0
for DISK in $DISKS; do
   echo $DISK
   if [ -b /dev/$DISK ];
   then
      echo "Mounting $DISK"
      umount /dev/$DISK || echo 'not mounted'
      mkfs.xfs -f /dev/$DISK
      mkdir -p /data$DISK_IDX
      sed -i "/$DISK/d" /etc/fstab
      echo "/dev/$DISK /data$DISK_IDX auto defaults,nobootwait,comment=cloudconfig 0 2" >> /etc/fstab
      DISK_IDX=$((DISK_IDX+1))
   fi
done
cat /etc/fstab
mount -a

