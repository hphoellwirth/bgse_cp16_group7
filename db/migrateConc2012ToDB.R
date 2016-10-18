# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Migrate pollution concentration data until 2012 into database
#
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Loading xls data
# ----------------------------------------------------------------------

# house cleaning
rm(list = ls())

# install/load libraries
if(!require(openxlsx)){install.packages("openxlsx")}
if(!require(RMySQL)){install.packages("RMySQL")}
if(!require(mgcv)){install.packages("mgcv")}

library("openxlsx")
library("RMySQL")
library("mgcv")

# if interactive, during the development, set to TRUE
interactive <- FALSE
if (interactive) {
    setwd("/Users/Hans-Peter/Documents/Masters/14D003/project")
} 
loadFileName <- "data/Air pollutant concentrations 2012 - Dataset complete.xlsx"

# load data
dat_PM10  <- read.xlsx(loadFileName, sheet = 2, startRow = 11, colNames = TRUE)
dat_NO2   <- read.xlsx(loadFileName, sheet = 5, startRow = 11, colNames = TRUE)
dat_O3    <- read.xlsx(loadFileName, sheet = 8, startRow = 11, colNames = TRUE)
dat_PM2.5 <- read.xlsx(loadFileName, sheet = 11, startRow = 11, colNames = TRUE)
dat_BaP   <- read.xlsx(loadFileName, sheet = 14, startRow = 11, colNames = TRUE)

# ----------------------------------------------------------------------
# Connect to mySQL database
# ----------------------------------------------------------------------
#system('ssh -i "../14D003.pem" ubuntu@54.171.170.201 -N sleep 20'')
dbConn = dbConnect(MySQL(), 
                   host='0.0.0.0', port=3306,
                   user='gseuser', password='gsepass', 
                   dbname='airpollution')

# ----------------------------------------------------------------------
# Insert data
# ----------------------------------------------------------------------

# support UTF-8 characters
dbGetQuery(dbConn, "set names utf8")

# countries
countries <- uniquecombs(data.frame(code = paste0("\"",dat_NO2$country_iso_code,"\""), 
                                    name = paste0("\"",dat_NO2$country_name,"\""),
                                    pctTraffic = dat_NO2$percentage_traffic_population))
query <- paste("INSERT INTO country",
               "(countryID, countryName, pctTraffic)",
               "VALUES (", apply(countries, 1, paste, collapse = ", "), ");")
invisible(lapply(query, function(q) dbGetQuery(dbConn, q)))

# cities
cities <- uniquecombs(data.frame(code = paste0("\"",dat_NO2$city_code,"\""),
                                 name = paste0("\"",dat_NO2$city_name,"\""),
                                 country = paste0("\"",dat_NO2$country_iso_code,"\""),
                                 population = dat_NO2$UA_city_pop))
query <- paste("INSERT INTO city",
               "(cityID, cityName, countryID, popluation)", 
               "VALUES(", apply(cities, 1, paste, collapse = ", "), ");")
invisible(lapply(query, function(q) dbGetQuery(dbConn, q)))

# stations
stations <- uniquecombs(data.frame(code = paste0("\"",dat_NO2$station_european_code,"\""),
                                   city = paste0("\"",dat_NO2$city_code,"\""),
                                   type = paste0("\"",dat_NO2$type_of_station,"\""),
                                   area = paste0("\"",dat_NO2$station_type_of_area,"\"")))
query <- paste("INSERT INTO station",
               "(stationID, cityID, stationType, areaType)",
               "VALUES (", apply(stations, 1, paste, collapse = ", "), ");")
invisible(lapply(query, function(q) dbGetQuery(dbConn, q)))

# concentration




