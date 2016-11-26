# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Interpolating population data
#
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Loading libraries
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Interpolating population data
#
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Loading libraries
# ----------------------------------------------------------------------

# house cleaning
rm(list = ls())

# load libraries
suppressMessages(if(!require(RMySQL)){install.packages("RMySQL")})
suppressMessages(if(!require(RMySQL)){install.packages("zoo")})
suppressMessages(library("zoo")) 
suppressMessages(library("RMySQL")) 

# ----------------------------------------------------------------------
# Connect to mySQL database
# ----------------------------------------------------------------------

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

# ----------------------------------------------------------------------
# Interpolating country population data
# ----------------------------------------------------------------------

# TBD: add regression

# ----------------------------------------------------------------------
# Interpolating city population data
# ----------------------------------------------------------------------
cityIDs <- dbGetQuery(dbConn, "SELECT cityID FROM cityPopulation group by cityID;")
# start.year <- dbGetQuery(dbConn, "SELECT min(year) FROM cityPopulation;")
end.year<- dbGetQuery(dbConn, "SELECT max(year) FROM cityPopulation;")
# start_year<- as.numeric(start.year)
end_year<- as.numeric(end.year)
print(end_year)

# #min number of data points needed to intrapolat/extrapolat the data
min.data=2

for (i in 1:length(cityIDs[ ,1])) {
  # run regression on existing population data
  #get data for one city at a time
  cityID<-as.character(cityIDs[i, ])
  getdata1<- paste0("SELECT cityID, population, year FROM cityPopulation WHERE cityID=\"", cityID, "\" ;")
  my_data<-dbGetQuery(dbConn, getdata1) 
  print(my_data)
  #get data about the year of the first observation
  getdata2<- paste0("SELECT min(year) FROM cityPopulation  WHERE cityID=\"", cityID, "\" ;")
  start.year <- dbGetQuery(dbConn, getdata2)
  start_year<- as.numeric(start.year)
  print(start_year)
  #get data about the year of the last observation
  # getdata3<- paste0("SELECT max(year) FROM cityPopulation  WHERE cityID=\"", cityID, "\" ;")
  # end.year<- dbGetQuery(dbConn, getdata3)
  # end_year<- as.numeric(end.year)
  
  ############################ works till here
  year<-seq(start_year, 2013)
  #create a data frame with the years and data needed fo the intrapolation
  popul_data<-as.data.frame(year)
  inserts <- c()
  if (length(my_data$year) >= min.data) {
    #add column for population and city name
    popul_data$population<-NA
    popul_data$cityID<-my_data$cityID[1]
    #insert the data from the observations present
    popul_data$population[match(my_data$year[my_data$year<2014], popul_data$year)]<-my_data$population[my_data$year<2014]
    #intrapolate the data 
    popul_data$population<-na.spline(popul_data$population)
    print(match(my_data$year[my_data$year<2014], popul_data$year))
    import.data<-popul_data[-match(my_data$year[my_data$year<2014], popul_data$year), ]
    print(import.data)
  }
  ############### works till here
  if (nrow(import.data)>0) {
    for (j in 1:nrow(import.data)){
      inserts <- c(inserts, paste0("(\"", import.data$cityID[j], "\",", import.data$year[j] , ",", import.data$population[j], ", true )"))
    }
  }
  if (length(inserts) > 0) {
    query <- paste("INSERT INTO cityPopulation",
                   "(cityID, year, population, interpolation)",
                   "VALUES", paste(inserts,collapse = ", "))
    dbGetQuery(dbConn, query)
  }
}

