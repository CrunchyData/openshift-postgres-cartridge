#!/bin/bash

#
# 1st parameter is the path to the postgres archive to upgrade with
# e.g. app-root/data/pg-9.3.4-crunchy.tar.gz
#

source $OPENSHIFT_CARTRIDGE_SDK_BASH

client_result "performing pg upgrade...." $1

mv $OPENSHIFT_PG_DIR/versions/pg $OPENSHIFT_PG_DIR/versions/pg-before-upgrade

mkdir $OPENSHIFT_PG_DIR/versions/pg

tar xvzf $OPENSHIFT_HOMEDIR/$1 --directory=$OPENSHIFT_PG_DIR/versions/pg

