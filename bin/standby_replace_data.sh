#!/bin/bash 

version=pg

echo "replacing standby data with the master backup...."
mv $OPENSHIFT_DATA_DIR/.$version/data  $OPENSHIFT_DATA_DIR/.$version/data.orig
mkdir $OPENSHIFT_DATA_DIR/.$version/data 

chmod 700 $OPENSHIFT_DATA_DIR/.$version/data

pg_basebackup -R  \
--pgdata=$OPENSHIFT_DATA_DIR/.$version/data \
--host=$OPENSHIFT_PG_HOST --port=15000 -U $JEFF_MASTER_USER

echo "reconfiguring postgres conf files...."

sleep 4

~/$version/bin/configure.sh
