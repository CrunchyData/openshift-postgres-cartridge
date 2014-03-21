#!/bin/bash

NODE1_IP=`nslookup broker.example.com | grep Address | tail -1 | cut -d ":" -f 2`
NODE2_IP=`nslookup broker.example.com | grep Address | tail -1 | cut -d ":" -f 2`
ssh-keygen -R `echo $NODE1_IP`
ssh-keygen -R `echo $NODE2_IP`

echo "cleaning up previous installs...."

ssh-keygen -R pgmaster-otest.example.com
ssh-keygen -R pgstandby-otest.example.com
rhc app-delete -a pgmaster --confirm
rhc app-delete -a pgstandby --confirm
/bin/rm -rf pgmaster
/bin/rm -rf pgstandby

rhc create-app -a pgmaster -t php-5.3
rhc create-app -a pgstandby -t php-5.3 

echo "generating key...."
/bin/rm pg932_rsa_key*

ssh-keygen -f pg932_rsa_key -N ''

echo "copying key to servers...."
scp -o StrictHostKeyChecking=no pg932_rsa_key $MASTER:~/app-root/data
scp -o StrictHostKeyChecking=no pg932_rsa_key $STANDBY:~/app-root/data

echo "removing openshift domain key..."
rhc sshkey remove -i pg932_key

echo "adding key to openshift domain...."
rhc sshkey add -i pg932_key -k ./pg932_rsa_key.pub

echo "pgmaster created..."
rhc add-cartridge https://raw.githubusercontent.com/crunchyds/openshift-postgres-932-rh65-cart/master/metadata/manifest.yml?token=863211__eyJzY29wZSI6IlJhd0Jsb2I6Y3J1bmNoeWRzL29wZW5zaGlmdC1wb3N0Z3Jlcy05MzItcmg2NS1jYXJ0L21hc3Rlci9tZXRhZGF0YS9tYW5pZmVzdC55bWwiLCJleHBpcmVzIjoxMzk1OTQ0Mjc4fQ%3D%3D--3bda6243649c055f749c5b52ac3be231ae858d65 -a pgmaster --env JEFF_NODE_TYPE=master
echo "added pg932 to pgmaster...."

#rhc create-app -a pgstandby -t php-5.3 -g node2profile
echo "pgstandby created..."

rhc add-cartridge https://raw.githubusercontent.com/crunchyds/openshift-postgres-932-rh65-cart/master/metadata/manifest.yml?token=863211__eyJzY29wZSI6IlJhd0Jsb2I6Y3J1bmNoeWRzL29wZW5zaGlmdC1wb3N0Z3Jlcy05MzItcmg2NS1jYXJ0L21hc3Rlci9tZXRhZGF0YS9tYW5pZmVzdC55bWwiLCJleHBpcmVzIjoxMzk1OTQ0Mjc4fQ%3D%3D--3bda6243649c055f749c5b52ac3be231ae858d65 -a pgstandby --env JEFF_NODE_TYPE=standby
echo "added pg932 to pgstandby..."

export MASTER=`rhc domain show | grep SSH | grep master | cut -d ':' -f 2 | tr -s " "`
export STANDBY=`rhc domain show | grep SSH | grep standby | cut -d ':' -f 2 | tr -s " "`

#echo "MASTER=" $MASTER
#echo "STANDBY=" $STANDBY



#ssh -o StrictHostKeyChecking=no $STANDBY '~/pg932/bin/set_ssh_info.sh master ' $MASTER
#echo "configured port forwarding on standby..."

#ssh -o StrictHostKeyChecking=no $MASTER  '~/pg932/bin/set_ssh_info.sh standby ' $STANDBY
#echo "configured port forwarding on master..."

#ssh -o StrictHostKeyChecking=no $MASTER '~/pg932/bin/grant.sh'
#echo "set admin rights on master user..."

echo "stopping postgres on both servers..."
ssh -o StrictHostKeyChecking=no $MASTER  '~/pg932/bin/control stop'
ssh -o StrictHostKeyChecking=no $STANDBY '~/pg932/bin/control stop'
sleep 7

ssh -o StrictHostKeyChecking=no $MASTER '~/pg932/bin/configure.sh'
echo "configured master for replication.."
ssh -o StrictHostKeyChecking=no $STANDBY '~/pg932/bin/configure.sh'
echo "configured standby for replication.."

ssh -o StrictHostKeyChecking=no $MASTER '~/pg932/bin/control start'
echo "started master..."
sleep 7

ssh  -o StrictHostKeyChecking=no $STANDBY  '~/pg932/bin/standby_replace_data.sh'
echo "created backup for standby server..."

ssh -o StrictHostKeyChecking=no $STANDBY '~/pg932/bin/control start'
sleep 7
echo "started standby server...."
echo "replication setup complete"

