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
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=~/pg932/known_hosts \
 -i ~/pg932/pg932_rsa_key \
$PG_REMOTE_USER@$PG_REMOTE_HOST \
 'echo $OPENSHIFT_PG_HOST' > ~/pg932/env/PG_REMOTE_INTERNAL_IP

echo $PG_REMOTE_SSH_STRING > ~/pg932/env/PG_REMOTE_SSH_STRING
echo $PG_REMOTE_USER > ~/pg932/env/PG_REMOTE_USER
echo $PG_REMOTE_HOST > ~/pg932/env/PG_REMOTE_HOST
echo $PG_NODE_TYPE > ~/pg932/env/PG_NODE_TYPE
