mkdir ceph
cd ceph

#create monitor nodes
ceph-deploy new n13 n14 n15
cat >> ceph.conf << EOF
osd pool default size = 2
osd journal size = 2000
mon clock drift allowed = 2
mon clock drift warn backoff = 30
mon allow pool delete = true
EOF
ceph-deploy mon create-initial

ceph-deploy admin n13 n14 n15
ceph-deploy mgr create n13:mon_mgr

#remove exist ceph vg pv
vgremove -f `vgs |grep ceph | awk '{print $1}'`
pvremove /dev/vd{c..e}

#create osd with vdc vdd vde on n13 n14 n15
ceph-deploy osd create --data /dev/vdc n13
ceph-deploy osd create --data /dev/vdd n14
ceph-deploy osd create --data /dev/vde n15

#create rbd pool
#ceph osd pool create rbd 80 80
#ceph osd pool set rbd size 2 
#ceph osd pool application enable rbd rbd 
#rbd create disk1 -s 100G --image-feature layering

#create cephfs
ceph-deploy mds create n{13..15}
ceph osd pool create cephfs_data 100
ceph osd pool create cephfs_metadata 100
ceph fs new cephfs cephfs_metadata cephfs_data
ceph fs ls

#create mgr dashboard
ceph mgr module enable dashboard
ceph dashboard create-self-signed-cert
ceph dashboard set-login-credentials admin admin
ceph mgr services

#create auth key
ceph-authtool -p /etc/ceph/ceph.client.admin.keyring > /root/admin.key
echo "mount -t ceph n13:6789:/ /mnt -o name=admin,secretfile=admin.key"
echo "ceph-fuse -m n13:6789,n14:6789,n15:6789 /mnt"
