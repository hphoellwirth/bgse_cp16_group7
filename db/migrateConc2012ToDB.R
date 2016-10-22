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

# support UTF-8 characters
invisible(dbGetQuery(dbConn, "set names utf8"))

# ----------------------------------------------------------------------
# Assign dummy cityIDs to TR cities
# ----------------------------------------------------------------------
dat_NO2[dat_NO2$city_code == "NULL",]$city_code <- 
    paste0(dat_NO2[dat_NO2$city_code == "NULL",]$country_iso_code,
           substr(dat_NO2[dat_NO2$city_code == "NULL",]$city_name,1,5))

dat_O3[dat_O3$city_code == "NULL",]$city_code <- 
    paste0(dat_O3[dat_O3$city_code == "NULL",]$country_iso_code,
           substr(dat_O3[dat_O3$city_code == "NULL",]$city_name,1,5))

dat_PM10[dat_PM10$city_code == "NULL",]$city_code <- 
    paste0(dat_PM10[dat_PM10$city_code == "NULL",]$country_iso_code,
           substr(dat_PM10[dat_PM10$city_code == "NULL",]$city_name,1,5))

# ----------------------------------------------------------------------
# Insert countries
# ----------------------------------------------------------------------
countries <- uniquecombs(rbind(data.frame(code = paste0("\"",dat_NO2$country_iso_code,"\""), 
                                          name = paste0("\"",dat_NO2$country_name,"\""),
                                          pctTraffic = dat_NO2$percentage_traffic_population),
                               data.frame(code = paste0("\"",dat_O3$country_iso_code,"\""), 
                                          name = paste0("\"",dat_O3$country_name,"\""),
                                          pctTraffic = dat_O3$percentage_traffic_population),
                               data.frame(code = paste0("\"",dat_PM10$country_iso_code,"\""), 
                                          name = paste0("\"",dat_PM10$country_name,"\""),
                                          pctTraffic = dat_PM10$percentage_traffic_population)))
inserts <- apply(countries, 1, paste, collapse = ", ")
query <- paste("INSERT INTO country",
               "(countryID, countryName, pctTraffic)",
               "VALUES (", paste(inserts, collapse = "), ("), ");")
invisible(lapply(query, function(q) dbGetQuery(dbConn, q)))

# ----------------------------------------------------------------------
# Insert cities
# ----------------------------------------------------------------------

# TBD: filter TR cities are assign them artificial ID

cities <- uniquecombs(rbind(data.frame(code = paste0("\"",dat_NO2$city_code,"\""),
                                       name = paste0("\"",dat_NO2$city_name,"\""),
                                       country = paste0("\"",dat_NO2$country_iso_code,"\""),
                                       population = dat_NO2$UA_city_pop),
                            data.frame(code = paste0("\"",dat_O3$city_code,"\""),
                                       name = paste0("\"",dat_O3$city_name,"\""),
                                       country = paste0("\"",dat_O3$country_iso_code,"\""),
                                       population = dat_O3$UA_city_pop),
                            data.frame(code = paste0("\"",dat_PM10$city_code,"\""),
                                       name = paste0("\"",dat_PM10$city_name,"\""),
                                       country = paste0("\"",dat_PM10$country_iso_code,"\""),
                                       population = dat_PM10$UA_city_pop)))
inserts <- apply(cities, 1, paste, collapse = ", ")
query <- paste("INSERT INTO city",
               "(cityID, cityName, countryID, popluation)", 
               "VALUES (", paste(inserts, collapse = "), ("), ");")
invisible(lapply(query, function(q) dbGetQuery(dbConn, q)))

# ----------------------------------------------------------------------
# Insert stations
# ----------------------------------------------------------------------
stations <- uniquecombs(rbind(data.frame(code = paste0("\"",dat_NO2$station_european_code,"\""),
                                         city = paste0("\"",dat_NO2$city_code,"\""),
                                         type = paste0("\"",dat_NO2$type_of_station,"\""),
                                         area = paste0("\"",dat_NO2$station_type_of_area,"\"")),
                              data.frame(code = paste0("\"",dat_O3$station_european_code,"\""),
                                         city = paste0("\"",dat_O3$city_code,"\""),
                                         type = paste0("\"",dat_O3$type_of_station,"\""),
                                         area = paste0("\"",dat_O3$station_type_of_area,"\"")),
                              data.frame(code = paste0("\"",dat_PM10$station_european_code,"\""),
                                         city = paste0("\"",dat_PM10$city_code,"\""),
                                         type = paste0("\"",dat_PM10$type_of_station,"\""),
                                         area = paste0("\"",dat_PM10$station_type_of_area,"\""))))
inserts <- apply(stations, 1, paste, collapse = ", ")
query <- paste("INSERT INTO station",
               "(stationID, cityID, stationType, areaType)",
               "VALUES (", paste(inserts, collapse = "), ("), ");")
invisible(lapply(query, function(q) dbGetQuery(dbConn, q)))

# ----------------------------------------------------------------------
# Insert concentrations
# ----------------------------------------------------------------------

# NO2 concentrations
conc <- uniquecombs(data.frame(station = paste0("\"",dat_NO2$station_european_code,"\""),
                               year = dat_NO2$statistics_year,
                               value = dat_NO2$statistic_value,
                               valid = dat_NO2$statistics_percentage_valid,
                               mcode = paste0("\"",dat_NO2$measurement_european_group_code,"\""),
                               population = dat_NO2$assigned_population))
inserts <- paste("(\"NO2\", ", apply(conc, 1, paste, collapse = ", "), ")")
query <- paste("INSERT INTO concentration",
               "(pollutantID, stationID, year, concentration, pctValid, measurementCode, population)",
               "VALUES", paste(inserts,collapse = ", "))
invisible(lapply(query, function(q) dbGetQuery(dbConn, q)))

# O3 concentrations
conc <- uniquecombs(data.frame(station = paste0("\"",dat_O3$station_european_code,"\""),
                               year = dat_O3$statistics_year,
                               value = dat_O3$statistic_value,
                               valid = dat_O3$statistics_percentage_valid,
                               mcode = paste0("\"",dat_O3$measurement_european_group_code,"\""),
                               population = dat_O3$assigned_population))
inserts <- paste("(\"O3\", ", apply(conc, 1, paste, collapse = ", "), ")")
query <- paste("INSERT INTO concentration",
               "(pollutantID, stationID, year, concentration, pctValid, measurementCode, population)",
               "VALUES", paste(inserts,collapse = ", "))
invisible(lapply(query, function(q) dbGetQuery(dbConn, q)))

# PM10 concentrations
conc <- uniquecombs(data.frame(station = paste0("\"",dat_PM10$station_european_code,"\""),
                               year = dat_PM10$statistics_year,
                               value = dat_PM10$statistic_value,
                               valid = dat_PM10$statistics_percentage_valid,
                               mcode = paste0("\"",dat_PM10$measurement_european_group_code,"\""),
                               population = dat_PM10$assigned_population))
inserts <- paste("(\"PM10\", ", apply(conc, 1, paste, collapse = ", "), ")")
query <- paste("INSERT INTO concentration",
               "(pollutantID, stationID, year, concentration, pctValid, measurementCode, population)",
               "VALUES", paste(inserts,collapse = ", "))
invisible(lapply(query, function(q) dbGetQuery(dbConn, q)))




