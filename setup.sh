#!/bin/bash

# installion script

cmd=$1

user=`grep dbuser service.conf | cut -f2 -d' '`
pswd=`grep dbpswd service.conf | cut -f2 -d' '`

target_dir='/var/www/html'
#target_dir=$HOME/public_html

case $cmd in

install)
	echo "Installing"
	
    # 1. Decompress data files
    tar xf data/CLRTAP_NFR14_V16_GF.tar.gz -C data		

    # 2. Create mySQL database
    echo "... setting up database"
    mysql -u $user -p$pswd < db/ddl_airpollution.sql
    
    # 3. Migrate data to mySQL database
    echo "... migrating data"
    mysql -u $user -p$pswd -t < db/dml_pre_migration.sql    
    Rscript db/migrateConc2012ToDB.R $user $pswd
    Rscript db/migrateConc2013ToDB.R $user $pswd
    Rscript db/migrateEmissionsToDB.R $user $pswd
    Rscript db/migrateGeoDataToDB.R $user $pswd
    Rscript db/migratePopulationsToDB.R $user $pswd
    mysql -u $user -p$pswd -t < db/dml_post_migration.sql
    rm data/CLRTAP_NFR14_V16_GF.csv   
    
    # 4. Optimize database performance
    echo "... optimizing performance"
    mysql -u $user -p$pswd < db/ddl_performance.sql   

    # 5. Create web dashboard
    echo "... setting up dashboard"
    mysql -u $user -p$pswd < db/ddl_dashboard.sql 
    sudo mkdir -p "$target_dir/airpollution"
    sudo cp -rf web/* "$target_dir/airpollution"

	echo "done!"
	;;

uninstall)
	echo "Uninstalling"
	
	echo "... deleting database"
	mysql -u $user -p$pswd -e "DROP DATABASE airpollution;" 
	
	echo "... deleting dashboard"
	rm -rf "target_dir/airpollution"

	echo "done!"
	;;

run)
	echo "Running"
	echo "... interpolating population data"	
	Rscript analysis/preInterpolatePopulation.R $user $pswd
	echo "... computing descriptive analysis"	
	mysql -u $user -p$pswd < db/ddl_analysis.sql 
	Rscript analysis/descCorrLocation.R $user $pswd
	Rscript analysis/descCorrPopulation.R $user $pswd
	echo "... computing predictive analysis"
	Rscript analysis/predConcCountry.R $user $pswd
	Rscript analysis/predConcStation.R $user $pswd

  echo "done!"
	;;

*)
	echo "Unknown Command!"

esac
