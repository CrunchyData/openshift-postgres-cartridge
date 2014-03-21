#!/bin/bash -e

version=pg

source $OPENSHIFT_CARTRIDGE_SDK_BASH

if [ "$PG_NODE_TYPE" == "master" ]; then
        client_result "configuring master postgres server "
        erb  ~/$version/conf/master/pg_hba.conf.erb > $OPENSHIFT_DATA_DIR/.$version/data/pg_hba.conf
        erb  ~/$version/conf/master/postgresql.conf.erb > $OPENSHIFT_DATA_DIR/.$version/data/postgresql.conf
else
if [ "$PG_NODE_TYPE" == "standby" ]; then
        client_result "configuring standby postgres server this time"
        erb  ~/$version/conf/standby/pg_hba.conf.erb > $OPENSHIFT_DATA_DIR/.$version/data/pg_hba.conf
        erb  ~/$version/conf/standby/postgresql.conf.erb > $OPENSHIFT_DATA_DIR/.$version/data/postgresql.conf
        erb  ~/$version/conf/standby/recovery.conf.erb > $OPENSHIFT_DATA_DIR/.$version/data/recovery.conf
else
    client_result "problem found....server is not marked as master or standby"
fi
fi

