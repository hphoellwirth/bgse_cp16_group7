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
    #tar xf data/CLRTAP_NFR14_V16_GF.csv.zip -C data	

    # 2. Create mySQL database
	mysql -u $user -p$pswd < db/ddl_airpollution.sql
    mysql -u $user -p$pswd -t < db/dml_pollutants.sql
    
    # 3. Migrate data to mySQL database
    Rscript db/migrateConc2012ToDB.R
    #Rscript db/migrateConc2013ToDB.R
    #Rscript db/migrateEmissionsToDB.R 
    #rm data/CLRTAP_NFR14_V16_GF.csv   

    # 4. Create web dashboard
	mkdir -p "$target_dir/airpollution"
	cp -rf web/* "$target_dir/airpollution"

	echo "done!"
	;;

uninstall)
	echo "Uninstalling"
	
	mysql -u $user -p$pswd -e "DROP DATABASE airpollution;" 
	rm -rf "target_dir/airpollution"

	echo "done!"
	;;

run)
	echo "Running"
	#R CMD BATCH analysis/analysis.R 
	#cat analysis.Rout
	#rm analysis.Rout
	#cp web/categories_network.png "$target_dir/airpollution"

	;;

*)
	echo "Unknown Command!"

esac