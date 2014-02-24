#!/bin/bash -x

nohup ssh -o UserKnownHostsFile=~/pg932/known_hosts \
-i ~/pg932/pg932_rsa_key \
-N -L \
$OPENSHIFT_PG_HOST:15000:$PG_REMOTE_INTERNAL_IP:5432 \
$PG_REMOTE_USER@$PG_REMOTE_HOST &> /dev/null &

