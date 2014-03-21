#!/bin/bash -x

echo mode is $1
echo ssh string is $2

export PG_REMOTE_SSH_STRING=$2
arr=($(echo $PG_REMOTE_SSH_STRING | tr "@" "\n"))
export PG_REMOTE_USER=${arr[0]}
export PG_REMOTE_HOST=${arr[1]}

echo remote user is $PG_REMOTE_USER
echo remote host is $PG_REMOTE_HOST

if [ "$1" == "master" ]; then
        export PG_NODE_TYPE=standby
        echo "we are a standby node...."
else
        export PG_NODE_TYPE=master
        echo "we are a master node...."
fi

#
# get the remote internal IP address and make it available for tunnels
#
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=~/app-root/data/known_hosts \
 -i ~/app-root/data/pg_rsa_key \
$PG_REMOTE_USER@$PG_REMOTE_HOST \
 'echo $OPENSHIFT_PG_HOST' > ~/pg/env/PG_REMOTE_INTERNAL_IP

PG_REMOTE_INTERNAL_IP=`cat ~/pg/env/PG_REMOTE_INTERNAL_IP`
echo "setting PG_REMOTE_INTERANAL_IP is " $PG_REMOTE_INTERNAL_IP
echo $PG_REMOTE_SSH_STRING > ~/pg/env/PG_REMOTE_SSH_STRING
echo $PG_REMOTE_USER > ~/pg/env/PG_REMOTE_USER
echo $PG_REMOTE_HOST > ~/pg/env/PG_REMOTE_HOST
echo $PG_NODE_TYPE > ~/pg/env/PG_NODE_TYPE

# give the environment variables some time to take effect before
# creating the tunnels

sleep 4

#source ~/pg/bin/create-tunnel.sh
