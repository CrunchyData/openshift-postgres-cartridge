#!/bin/bash

SQL_FILE=/tmp/grant.sql

echo "alter role " \"$USER\" " with replication" > /tmp/grant.sql
psql -U $USER template1 < $SQL_FILE

