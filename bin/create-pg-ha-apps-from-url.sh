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
/bin/rm pg_rsa_key*

ssh-keygen -f pg_rsa_key -N ''

echo "removing openshift domain key..."
rhc sshkey remove -i pg_key

echo "adding key to openshift domain...."
rhc sshkey add -i pg_key -k ./pg_rsa_key.pub

echo "copying key to servers...."
rhc scp pgmaster upload pg_rsa_key app-root/data
rhc scp pgstandby upload pg_rsa_key app-root/data
#export MASTER=`rhc domain show | grep SSH | grep master | cut -d ':' -f 2 | tr -s " "`
#export STANDBY=`rhc domain show | grep SSH | grep standby | cut -d ':' -f 2 | tr -s " "`
#scp -o StrictHostKeyChecking=no pg_rsa_key $MASTER:~/app-root/data
#scp -o StrictHostKeyChecking=no pg_rsa_key $STANDBY:~/app-root/data


echo "pgmaster created..."
rhc add-cartridge https://raw.githubusercontent.com/crunchyds/openshift-postgres-cartridge/master/metadata/manifest.yml?token=863211__eyJzY29wZSI6IlJhd0Jsb2I6Y3J1bmNoeWRzL29wZW5zaGlmdC1wb3N0Z3Jlcy1jYXJ0cmlkZ2UvbWFzdGVyL21ldGFkYXRhL21hbmlmZXN0LnltbCIsImV4cGlyZXMiOjEzOTYwMTg1MTh9--7853bf8d123b4f54346faeb18568f0d7ea026138 -a pgmaster --env JEFF_NODE_TYPE=master
echo "added Crunchy postgres cartridge to pgmaster...."

echo "pgstandby created..."

rhc add-cartridge https://raw.githubusercontent.com/crunchyds/openshift-postgres-cartridge/master/metadata/manifest.yml?token=863211__eyJzY29wZSI6IlJhd0Jsb2I6Y3J1bmNoeWRzL29wZW5zaGlmdC1wb3N0Z3Jlcy1jYXJ0cmlkZ2UvbWFzdGVyL21ldGFkYXRhL21hbmlmZXN0LnltbCIsImV4cGlyZXMiOjEzOTYwMTg1MTh9--7853bf8d123b4f54346faeb18568f0d7ea026138 -a pgstandby --env JEFF_NODE_TYPE=standby
echo "added Crunchy postgres cartridge to pgstandby..."

echo "stopping postgres on both servers..."
rhc ssh -a pgmaster --command '~/pg/bin/control stop'
rhc ssh -a pgstandby --command '~/pg/bin/control stop'
sleep 7

#ssh -o StrictHostKeyChecking=no $MASTER '~/pg/bin/configure.sh'
rhc ssh -a pgmaster --command '~/pg/bin/configure.sh'
echo "configured master for replication.."
rhc ssh -a pgstandby --command '~/pg/bin/configure.sh'
echo "configured standby for replication.."

rhc ssh -a pgmaster --command '~/pg/bin/control start'
echo "started master..."
sleep 7

rhc ssh -a pgstandby --command '~/pg/bin/standby_replace_data.sh'
echo "created backup for standby server..."

rhc ssh -a pgstandby --command '~/pg/bin/control start'
sleep 7
echo "started standby server...."
echo "replication setup complete"

