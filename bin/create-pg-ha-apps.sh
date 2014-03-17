#!/bin/bash

echo "remove keys from local known_hosts if they exist"
ssh-keygen -R pgmaster-jeffmc.example.com
ssh-keygen -R pgstandby-jeffmc.example.com
NODE1_IP=`nslookup node.example.com | grep Address | tail -1 | cut -d ":" -f 2`
NODE2_IP=`nslookup node2.example.com | grep Address | tail -1 | cut -d ":" -f 2`
ssh-keygen -R `echo $NODE1_IP`
ssh-keygen -R `echo $NODE2_IP`

echo "setting up pg932 replication...."

/bin/rm -rf pgmaster

rhc create-app -a pgmaster -t php-5.3
echo "pgmaster created..."

/bin/rm -rf pgstandby

rhc create-app -a pgstandby -t php-5.3 -g node2profile
echo "pgstandby created..."

rhc add-cartridge crunchydatasolutions-pg932-0.1 -a pgmaster
echo "added pg932 to pgmaster...."

rhc add-cartridge crunchydatasolutions-pg932-0.1 -a pgstandby
echo "added pg932 to pgstandby..."

export MASTER=`rhc domain show | grep SSH | grep master | cut -d ':' -f 2 | tr -s " "`
export STANDBY=`rhc domain show | grep SSH | grep standby | cut -d ':' -f 2 | tr -s " "`

echo "MASTER=" $MASTER
echo "STANDBY=" $STANDBY


echo "generating key...."
/bin/rm pg932_rsa_key*

ssh-keygen -f pg932_rsa_key -N ''

echo "copying key to servers...."
scp -o StrictHostKeyChecking=no pg932_rsa_key $MASTER:~/pg932
scp -o StrictHostKeyChecking=no pg932_rsa_key $STANDBY:~/pg932

echo "removing openshift domain key..."
rhc sshkey remove -i pg932_key

echo "adding key to openshift domain...."
rhc sshkey add -i pg932_key -k ./pg932_rsa_key.pub

ssh -o StrictHostKeyChecking=no $STANDBY '~/pg932/bin/set_ssh_info.sh master ' $MASTER
echo "configured port forwarding on standby..."

ssh -o StrictHostKeyChecking=no $MASTER  '~/pg932/bin/set_ssh_info.sh standby ' $STANDBY
echo "configured port forwarding on master..."

ssh -o StrictHostKeyChecking=no $MASTER '~/pg932/bin/grant.sh'
echo "set admin rights on master user..."

echo "stopping postgres on both servers..."
ssh -o StrictHostKeyChecking=no $MASTER  '~/pg932/bin/control stop'
ssh -o StrictHostKeyChecking=no $STANDBY '~/pg932/bin/control stop'

ssh -o StrictHostKeyChecking=no $MASTER '~/pg932/bin/configure.sh'
echo "configured master for replication.."
ssh -o StrictHostKeyChecking=no $STANDBY '~/pg932/bin/configure.sh'
echo "configured standby for replication.."

ssh -o StrictHostKeyChecking=no $MASTER '~/pg932/bin/control start'
echo "started master..."

ssh  -o StrictHostKeyChecking=no $STANDBY  '~/pg932/bin/standby_replace_data.sh'
echo "created backup for standby server..."

ssh -o StrictHostKeyChecking=no $STANDBY '~/pg932/bin/control start'
echo "started standby server...."
echo "replication setup complete"

