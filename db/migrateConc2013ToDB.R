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
# install/load libraries
suppressMessages(if(!require(openxlsx)){install.packages("openxlsx")})
suppressMessages(if(!require(RMySQL)){install.packages("RMySQL")})
suppressMessages(if(!require(mgcv)){install.packages("mgcv")})

suppressMessages(library("openxlsx"))
suppressMessages(library("RMySQL"))
suppressMessages(library("mgcv"))
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
# load arguments: db user and password
args <- commandArgs(trailingOnly = TRUE)
if (!is.na(args[1])) dbUser <- args[1]
if (!is.na(args[2])) dbPswd <- args[2]

# connect to database
dbConn = dbConnect(MySQL(),
                   host='0.0.0.0', port=3306,
                   user=dbUser, password=dbPswd, 
                   dbname='airpollution')
# support UTF-8 characters
invisible(dbGetQuery(dbConn, "set names utf8"))
# 
# 
# # ----------------------------------------------------------------------
# # Insert concentrations
# # ----------------------------------------------------------------------
##------------------------------------------------------------------------------------------------------------ 
##Insert concentration PM_10
##-----------------------------------------------------

stations <- dbGetQuery(dbConn, "SELECT stationID FROM station;")
for (i in 1:dim(stations)[1]) {
  station<- as.character(stations[i,])
  value <-dat_PM10[dat_PM10$station_european_code == station, ]
  
  if (dim(value)[1] == 1){
    
    query<-  paste0("INSERT INTO concentration ",
                    "(pollutantID, stationID, year, concentration) ",
                    "VALUES ( " ,"\"", value$component_caption,"\"",  ",", "\"", value$station_european_code,"\"" ,",", " 2013 ", ",", value$statistic_value, ");")
    
    invisible(dbGetQuery(dbConn, query))
  }
}




##-----------------------------------------------------------------------------------------------------------
##Insert concentration N02
##----------------------------------------------------------------------------------------------------------
stations <- dbGetQuery(dbConn, "SELECT stationID FROM station;")
for (i in 1:dim(stations)[1])  {
  station<- as.character(stations[i,])
  value <-dat_NO2[dat_NO2$station_european_code == station, ]
  
  if (dim(value)[1] == 1){
    
    query<-  paste0("INSERT INTO concentration ",
                    "(pollutantID, stationID, year, concentration) ",
                    "VALUES ( " ,"\"", value$component_caption,"\"",  ",", "\"", value$station_european_code,"\"" ,",", " 2013 ", ",", value$statistic_value, ");")
    
    invisible(dbGetQuery(dbConn, query))
  }
}

##---------------------------------------------------------------------------------------------------------
##Insert concentration O3
##---------------------------------------------------------------------------------------------------------


stations <- dbGetQuery(dbConn, "SELECT stationID FROM station;")
for (i in 1:dim(stations)[1]) {
  station<- as.character(stations[i,])
  value <-dat_O3[dat_O3$station_european_code == station, ]
  
  if (dim(value)[1] == 1){
    
    query<-  paste0("INSERT INTO concentration ",
                    "(pollutantID, stationID, year, concentration) ",
                    "VALUES ( " ,"\"", value$component_caption,"\"",  ",", "\"", value$station_european_code,"\"" ,",", " 2013 ", ",", value$statistic_value, ");")
    
    invisible(dbGetQuery(dbConn, query))
  } 
}

##-------------------------------------------------------------------------------------------------------
##Insert concentration PM2.5
##-----------------------------------------------------------------------------------------------------
stations <- dbGetQuery(dbConn, "SELECT stationID FROM station;")
for (i in 1:dim(stations)[1]) {
  station<- as.character(stations[i,])
  value <-dat_PM2.5[dat_PM2.5$station_european_code == station, ]
  
  if (dim(value)[1] == 1){
    
    query<-  paste0("INSERT INTO concentration ",
                    "(pollutantID, stationID, year, concentration) ",
                    "VALUES ( " ,"\"", value$component_caption,"\"",  ",", "\"", value$station_european_code,"\"" ,",", " 2013 ", ",", value$statistic_value, ");")
    
    invisible(dbGetQuery(dbConn, query))
  }
}

##---------------------------------------------------------------------------------------------------
##Insert concentration BaP
##---------------------------------------------------------------------------------------------------
stations <- dbGetQuery(dbConn, "SELECT stationID FROM station;")
for (i in 1:dim(stations)[1])  {
  station<- as.character(stations[i,])
  value <-dat_BaP[dat_BaP$station_european_code == station, ]
  
  if (dim(value)[1] == 1){
    
    query<-  paste0("INSERT INTO concentration ",
                    "(pollutantID, stationID, year, concentration) ",
                    "VALUES ( " ,"\"", value$component_caption,"\"",  ",", "\"", value$station_european_code,"\"" ,",", " 2013 ", ",", value$statistic_value, ");")
    
    invisible(dbGetQuery(dbConn, query))
  }
}



