openshift-postgres-932-cart-rh65 
=============================

The Crunchy PG Cartridge is named crunchydatasolutions-pg-1.0. The Crunchy PG Cartridge will allow you to install a single standalone PostgreSQL server or a more complex configuration of a “master” and “standby” replication configuration. The Crunchy PG Cartridge includes a version of PostgreSQL 9.3.4. 


This version of PostgreSQL includes a fix applied to the pgstat.c source file that allows PostgreSQL to bind to an alternative host address rather than the default of localhost. This fix is required for running PostgreSQL on the current OpenShift platform due to the localhost (127.0.0.1) not being available for application use. The STATHOST environment variable is defined by this version of PostgreSQL for this purpose. 


The PostgreSQL port is 5432.  The database user is $USER, and the database
name is template1, all are default values.

The PostgreSQL data directory is found at ~/app-root/data/.pg

Test the installation with this command:

psql -U $USER -h $OPENSHIFT_PG_HOST template1

