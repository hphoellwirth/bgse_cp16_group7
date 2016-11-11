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
##----------------------------------------------------------------------------------------------------------
## Loading and inserting the concentration data simultaneously for the stations contained in the 2012 file
##-----------------------------------------------------------------------------------------------------------

# Create a vector giving the sheet loaded from the Excel file
sheet<-seq(1,5,1)

#Create a vector giving the staring row in each sheet
line<-c(10,11,11,11,11)

#Create a vector giving the pllutant type in each sheet 
pollutant<-c("PM10","NO2","O3", "PM2.5", "BaP")

# Creating a data frame containing all stations present in the 2012 file
stations <- dbGetQuery(dbConn, "SELECT stationID FROM station;")

# Creating a loop that first loads the data in each sheet and then checks if which station is contained
# in the 2012 file through the second for loop. 
# In case of having a match, we extract all the data that is present for the given station
# The if statement checks if whether or not a match is present and if yes- inserts the data in the 
# Concentration table in MySql
for (j in 1:length(line)){
  dat  <- read.xlsx(loadFileName, sheet = sheet[j], startRow = line[j], colNames = TRUE)
  for (i in 1:dim(stations)[1])  {
    station<- as.character(stations[i,])
    value <-dat[dat$station_european_code == station, ]
    
    if (dim(value)[1] == 1){
      
      query<-  paste0("INSERT INTO concentration ",
                      "(pollutantID, stationID, year, concentration) ",
                      "VALUES ( " ,"\"", pollutant[j], "\"",  ",", "\"", value$station_european_code,"\"" ,",", " 2013 ", ",", value$statistic_value, ");")
      invisible(dbGetQuery(dbConn, query))
    }
  }
}


