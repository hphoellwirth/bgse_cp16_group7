#!/bin/bash

### 1. Decompress data files
#tar xf data/CLRTAP_NFR14_V16_GF.csv.zip -C data


### 2. Create mySQL database
echo "Create mysql database 'airpollution'..."
mysql --user="gseuser" --password="gsepass" -t < db/ddl_airpollution.sql
mysql --user="gseuser" --password="gsepass" -t < db/dml_pollutants.sql


### 3. Migrate data to mySQL database
echo "Migrate data to database..."
Rscript db/migrateConc2012ToDB.R
#Rscript db/migrateConc2013ToDB.R
#Rscript db/migrateEmissionsToDB.R

#rm data/CLRTAP_NFR14_V16_GF.csv


### 4. Run data analytics 



### 5. Create web dashboard





