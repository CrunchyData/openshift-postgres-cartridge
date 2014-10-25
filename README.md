Openshift Postgres 9.3.4 Cartridge for OpenShift V2
=============================

The Crunchy PG Cartridge is named crunchydatasolutions-pg-1.0. The Crunchy PG Cartridge will allow you to install a single standalone PostgreSQL server or a more complex configuration of a “master” and “standby” replication configuration. The Crunchy PG Cartridge includes a version of PostgreSQL 9.3.4. 

This cartridge runs on Openshift v2, both Origin and Enterprise.

To install this in Origin V2, enter the following into the downloadable
cartridge "install your own cartridge" field:

http://cartreflect-claytondev.rhcloud.com/github/crunchyds/openshift-postgres-cartridge

This will use the reflector to add the Crunchy postgres cartridge to your
web application.


This version of PostgreSQL includes a fix applied to the pgstat.c source file that allows PostgreSQL to bind to an alternative host address rather than the default of localhost. This fix is required for running PostgreSQL on the current OpenShift platform due to the localhost (127.0.0.1) not being available for application use. The STATHOST environment variable is defined by this version of PostgreSQL for this purpose. 

This version also now includes the postgis extensions as well as
all the contrib extensions.

The PostgreSQL port is 5432.  The database user is $USER, and the database
name is template1, all are default values.

The PostgreSQL data directory is found at ~/app-root/data/.pg

Test the installation with this command:

psql -U $USER -h $OPENSHIFT_PG_HOST template1

