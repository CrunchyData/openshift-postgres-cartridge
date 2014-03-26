#!/bin/bash 

echo "create-tunnel called for " $PG_NODE_TYPE

if [ "$PG_NODE_TYPE" == "master" ]; then
nohup ssh -o UserKnownHostsFile=~/.openshift_ssh/known_hosts \
-i ~/.openshift_ssh/pg_rsa_key \
-N -L \
$OPENSHIFT_PG_HOST:15000:$PG_STANDBY_IP:5432 \
$PG_STANDBY_USER@$PG_STANDBY_DNS &> /dev/null &
fi

if [ "$PG_NODE_TYPE" == "standby" ]; then
nohup ssh -o UserKnownHostsFile=~/.openshift_ssh/known_hosts \
-i ~/.openshift_ssh/pg_rsa_key \
-N -L \
$OPENSHIFT_PG_HOST:15000:$PG_MASTER_IP:5432 \
$PG_MASTER_USER@$PG_MASTER_DNS &> /dev/null &
fi

