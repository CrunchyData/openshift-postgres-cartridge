#!/bin/bash -x

backup_dir=/tmp/postgres-data-backup`date +%G%m%d`
echo "creating postgres backup to " $backup_dir
pg_basebackup -h $OPENSHIFT_PG_HOST -D $backup_dir -Ft --xlog

scp -o UserKnownHostsFile=~/app-root/data/known_hosts -i ~/app-root/data/pg932_rsa_key $backup_dir/base.tar $PG_REMOTE_USER@$PG_REMOTE_HOST:~/pg932/

