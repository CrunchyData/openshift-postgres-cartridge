#!/bin/bash 

version=pg

./$version/bin/create-tunnel.sh

sleep 3

echo "replacing standby data with the master backup...."
mv $OPENSHIFT_DATA_DIR/.$version/data  $OPENSHIFT_DATA_DIR/.$version/data.orig
mkdir $OPENSHIFT_DATA_DIR/.$version/data 

chmod 700 $OPENSHIFT_DATA_DIR/.$version/data

pg_basebackup -R  \
--pgdata=$OPENSHIFT_DATA_DIR/.$version/data \
--host=$OPENSHIFT_PG_HOST --port=$PG_TUNNEL_PORT -U $PG_MASTER_USER

echo "reconfiguring postgres conf files...."

sleep 4

~/$version/bin/configure.sh
