# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Migrate pollution concentration data for 2013 into database
#
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Loading xls data
# ----------------------------------------------------------------------
# 
# # house cleaning
rm(list = ls())
# 
# # load libraries
library("mgcv")
library("openxlsx")
library("RMySQL")
# 
# # if interactive, during the development, set to TRUE
interactive <- FALSE
if (interactive) {
  setwd("/home/veronika/Documents/Project")
}
loadFileName <- "data/2013 data from air quality monitoring stations by city compared to EU values.xlsx"


# # load data
dat_PM10  <- read.xlsx(loadFileName, sheet = 1, startRow = 10, colNames = TRUE)
dat_NO2   <- read.xlsx(loadFileName, sheet = 2, startRow = 11, colNames = TRUE)
dat_O3    <- read.xlsx(loadFileName, sheet = 3, startRow = 11, colNames = TRUE)
dat_PM2.5 <- read.xlsx(loadFileName, sheet = 4, startRow = 11, colNames = TRUE)
dat_BaP   <- read.xlsx(loadFileName, sheet = 5, startRow = 11, colNames = TRUE)

# # ----------------------------------------------------------------------
# # Connect to mySQL database
# # ----------------------------------------------------------------------
# #system('ssh -i "../14D003.pem" ubuntu@54.171.170.201 -N sleep 20'')
dbConn = dbConnect(MySQL(),
                   host='0.0.0.0', port=3306,
                   user='gseuser', password='gsepass',
                   dbname='airpollution')

# 
# 
# # ----------------------------------------------------------------------
# # Insert concentrations
# # ----------------------------------------------------------------------
# 
# #create column for year=2013
# 
dat_PM10$statistics_year <- rep(2013, length(dat_PM10$city_name))
dat_NO2$statistics_year <-rep(2013, length(dat_NO2$city_name))
dat_O3$statistics_year <-rep(2013, length(dat_O3$city_name))
dat_PM2.5$statustics_year <-rep(2013, length(dat_PM2.5$city_name))
dat_BaP$statistics_year <-rep(2013, length(dat_BaP$city_name))

# 
# 
# 
# # NO2 concentrations
# conc <- uniquecombs (data.frame(station = paste0("\"",dat_NO2$station_european_code,"\""),
#                                 year = dat_NO2$statistics_year,
#                                 value = dat_NO2$statistic_value))
# inserts <- paste("(\"NO2\", ", apply(conc, 1, paste, collapse = ", "), ")")
# query <- paste("INSERT INTO concentration",
#                "(pollutantID, stationID, year, concentration)",
#                "VALUES", paste(inserts,collapse = ", "))
# dbGetQuery(dbConn, query)
# 
# # O3 concentrations
# conc <- uniquecombs (data.frame (station = paste0("\"",dat_O3$station_european_code,"\""),
#                                  year = dat_O3$statistics_year,
#                                  value = dat_O3$statistic_value ))
# inserts <- paste("(\"O3\", ", apply(conc, 1, paste, collapse = ", "), ")")
# query <- paste("INSERT INTO concentration",
#                "(pollutantID, stationID, year, concentration)",
#                "VALUES", paste(inserts,collapse = ", "))
# dbGetQuery(dbConn, query)
# 
# # PM10 concentrations
# conc <- uniquecombs(data.frame(station = paste0("\"",dat_PM10$station_european_code,"\""),
#                                year = dat_PM10$statistics_year,
#                                value = dat_PM10$statistic_value))
# 
# inserts <- paste("(\"PM10\", ", apply(conc, 1, paste, collapse = ", "), ")")
# query <- paste("INSERT INTO concentration",
#                "(pollutantID, stationID, year, concentration)",
#                "VALUES", paste(inserts,collapse = ", "))
# dbGetQuery(dbConn, query)
# 
# # PM2.5 concentrations
# conc <- uniquecombs(data.frame(station = paste0("\"",dat_PM2.5$station_european_code,"\""),
#                                year = dat_PM2.5$statustics_year,
#                                value = dat_PM2.5$`statistic_value.(µg/m3)` ))
# 
# 
# inserts <- paste("(\"PM2.5\", ", apply(conc, 1, paste, collapse = ", "), ")")
# query <- paste("INSERT INTO concentration",
#                "(pollutantID, stationID, year, concentration)",
#                "VALUES", paste(inserts,collapse = ", "))
# dbGetQuery(dbConn, query)
# 
# # BaP concentrations
# conc <- uniquecombs(data.frame(station = paste0("\"",dat_BaP$station_european_code,"\""),
#                                year = dat_BaP$statistics_year,
#                                value = dat_BaP$statistic_value))
# 
# inserts <- paste("(\"BaP\", ", apply(conc, 1, paste, collapse = ", "), ")")
# query <- paste("INSERT INTO concentration",
#                "(pollutantID, stationID, year, concentration)",
#                "VALUES", paste(inserts,collapse = ", "))
# dbGetQuery(dbConn, query)
# 




stations <- dbGetQuery(dbConn, "SELECT stationID FROM station;")

for (i in 1:dim(stations)[1]) {
  station<- as.charachter(stations[i,])
  value <-dat_PM10[dat_PM10$station_european_code == station, ]
  
  if (dim(value)[1] == 1){
    
    query<- paste0("INSERT INTO concentration", 
                   "(concID, pollutionID, stationID, year)",
                   "VALUES(\"", value$statistic_value ,"\",", value$component_caption, ",", value$station_european_code,",", "2013", ");")
    invisible(dbGetQuery(dbConn, query))  
  }
}

for (i in 1:dim(stations)[1]) {
  station<- as.charachter(stations[i,])
  value <-dat_NO2[dat_NO2$station_european_code == station, ]
  
  if (dim(value)[1] == 1){
    
    query<- paste0("INSERT INTO concentration", 
                   "(concID, pollutionID, stationID, year)",
                   "VALUES(\"", value$statistic_value ,"\",", value$component_caption, ",", value$station_european_code,",", "2013", ");")
    invisible(dbGetQuery(dbConn, query))  
  }
}


for (i in 1:dim(stations)[1]) {
  station<- as.charachter(stations[i,])
  value <-dat_O3[dat_O3$station_european_code == station, ]
  
  if (dim(value)[1] == 1){
    
    query<- paste0("INSERT INTO concentration", 
                   "(concID, pollutionID, stationID, year)",
                   "VALUES(\"", value$statistic_value ,"\",", value$component_caption, ",", value$station_european_code,",", "2013", ");")
    invisible(dbGetQuery(dbConn, query))  
  }
}



#
#
for (i in 1:dim(stations)[1]) {
  station<- as.charachter(stations[i,])
  value <-dat_PM2.5[dat_PM2.5$station_european_code == station, ]
  
  if (dim(value)[1] == 1){
    
    query<- paste0("INSERT INTO concentration", 
                   "(concID, pollutionID, stationID, year)",
                   "VALUES(\"", value$statistic_value ,"\",", value$component_caption, ",", value$station_european_code,",", "2013", ");")
    invisible(dbGetQuery(dbConn, query))  
  }
}

