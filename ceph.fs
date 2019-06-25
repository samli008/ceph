docker run -d --net=host --name=mds --restart=always \
-v /var/lib/ceph/:/var/lib/ceph/ \
-v /etc/ceph:/etc/ceph \
-e CEPHFS_CREATE=1 \
ceph/daemon mds

echo "Total PGs = ((Total_number_of_OSD * 100) / max_replication_count) / pool_count"
read -p "pls input cephfs pg number: " pg
docker exec mon ceph osd pool set cephfs_data size 2 
docker exec mon ceph osd pool get cephfs_data size 
docker exec mon ceph osd pool set cephfs_data pg_num $pg
docker exec mon ceph osd pool set cephfs_data pgp_num $pg
docker exec mon ceph osd pool get cephfs_data pg_num

read -p "pls input cephfs second node name: " node2
ssh $node2 \
docker run -d --net=host --name=mds --restart=always \
-v /var/lib/ceph/:/var/lib/ceph/ \
-v /etc/ceph:/etc/ceph \
ceph/daemon mds

read -p "pls input cephfs third node name: " node3
ssh $node3 \
docker run -d --net=host --name=mds --restart=always \
-v /var/lib/ceph/:/var/lib/ceph/ \
-v /etc/ceph:/etc/ceph \
ceph/daemon mds
