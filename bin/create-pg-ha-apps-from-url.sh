#!/bin/bash

# NODE1_IP=`nslookup broker.example.com | grep Address | tail -1 | cut -d ":" -f 2`
# NODE2_IP=`nslookup broker.example.com | grep Address | tail -1 | cut -d ":" -f 2`
# ssh-keygen -R `echo $NODE1_IP`
# ssh-keygen -R `echo $NODE2_IP`

echo "cleaning up previous installs...."

ssh-keygen -R pgmaster-otest.example.com
ssh-keygen -R pgstandby-otest.example.com
rhc app-delete -a pgmaster --confirm
rhc app-delete -a pgstandby --confirm
/bin/rm -rf pgmaster
/bin/rm -rf pgstandby

rhc create-app -a pgmaster -t php-5.3
rhc create-app -a pgstandby -t php-5.3 

#force a key to be added to your local known_hosts file
rhc ssh -a pgmaster --command 'date'
rhc ssh -a pgstandby --command 'date'

#now, get the keys for the pg servers from the local_hosts file
#and build a custom known_hosts file
rm /tmp/pg_known_hosts
touch /tmp/pg_known_hosts
chmod 600 /tmp/pg_known_hosts
ssh-keygen -F pgmaster-otest.example.com >> /tmp/pg_known_hosts
ssh-keygen -F pgstandby-otest.example.com >> /tmp/pg_known_hosts

#now, copy the pg known_hosts to the targets
rhc scp pgmaster upload /tmp/pg_known_hosts .openshift_ssh/known_hosts
rhc scp pgstandby upload /tmp/pg_known_hosts .openshift_ssh/known_hosts

#rhc create-app -a pgstandby -t php-5.3 -g node2profile

echo "generating pg apps key...."
/bin/rm pg932_rsa_key*

ssh-keygen -f pg932_rsa_key -N ''

echo "removing openshift domain key..."
rhc sshkey remove -i pg932_key

echo "adding key to openshift domain...."
rhc sshkey add -i pg932_key -k ./pg932_rsa_key.pub

echo "copying key to servers...."
rhc scp pgmaster upload pg932_rsa_key app-root/data
rhc scp pgstandby upload pg932_rsa_key app-root/data
#export MASTER=`rhc domain show | grep SSH | grep master | cut -d ':' -f 2 | tr -s " "`
#export STANDBY=`rhc domain show | grep SSH | grep standby | cut -d ':' -f 2 | tr -s " "`
#scp -o StrictHostKeyChecking=no pg932_rsa_key $MASTER:~/app-root/data
#scp -o StrictHostKeyChecking=no pg932_rsa_key $STANDBY:~/app-root/data


echo "pgmaster created..."
rhc add-cartridge https://raw.githubusercontent.com/crunchyds/openshift-postgres-932-rh65-cart/master/metadata/manifest.yml?token=863211__eyJzY29wZSI6IlJhd0Jsb2I6Y3J1bmNoeWRzL29wZW5zaGlmdC1wb3N0Z3Jlcy05MzItcmg2NS1jYXJ0L21hc3Rlci9tZXRhZGF0YS9tYW5pZmVzdC55bWwiLCJleHBpcmVzIjoxMzk1OTQ0Mjc4fQ%3D%3D--3bda6243649c055f749c5b52ac3be231ae858d65 -a pgmaster --env JEFF_NODE_TYPE=master
echo "added pg932 to pgmaster...."

echo "pgstandby created..."

rhc add-cartridge https://raw.githubusercontent.com/crunchyds/openshift-postgres-932-rh65-cart/master/metadata/manifest.yml?token=863211__eyJzY29wZSI6IlJhd0Jsb2I6Y3J1bmNoeWRzL29wZW5zaGlmdC1wb3N0Z3Jlcy05MzItcmg2NS1jYXJ0L21hc3Rlci9tZXRhZGF0YS9tYW5pZmVzdC55bWwiLCJleHBpcmVzIjoxMzk1OTQ0Mjc4fQ%3D%3D--3bda6243649c055f749c5b52ac3be231ae858d65 -a pgstandby --env JEFF_NODE_TYPE=standby
echo "added pg932 to pgstandby..."

echo "stopping postgres on both servers..."
rhc ssh -a pgmaster --command '~/pg932/bin/control stop'
rhc ssh -a pgstandby --command '~/pg932/bin/control stop'
sleep 7

#ssh -o StrictHostKeyChecking=no $MASTER '~/pg932/bin/configure.sh'
rhc ssh -a pgmaster --command '~/pg932/bin/configure.sh'
echo "configured master for replication.."
rhc ssh -a pgstandby --command '~/pg932/bin/configure.sh'
echo "configured standby for replication.."

rhc ssh -a pgmaster --command '~/pg932/bin/control start'
echo "started master..."
sleep 7

rhc ssh -a pgstandby --command '~/pg932/bin/standby_replace_data.sh'
echo "created backup for standby server..."

rhc ssh -a pgstandby --command '~/pg932/bin/control start'
sleep 7
echo "started standby server...."
echo "replication setup complete"

