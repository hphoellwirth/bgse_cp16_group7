#!/bin/bash

### 1. Decompress data files
tar xf data/CLRTAP_NFR14_V16_GF.csv.zip -C data


### 2. Create mySQL database
mysql -u gseuser -p gsepass -t < db/ddl_airpollution.sql


### 3. Migrate data to mySQL database
Rscript db/migrateConc2012ToDB.R
Rscript db/migrateConc2013ToDB.R
Rscript db/migrateEmissionsToDB.R

rm data/CLRTAP_NFR14_V16_GF.csv


### 4. Run data analytics 



### 5. Create web dashboard





