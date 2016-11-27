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
dbGetQuery(dbConn, "DELETE FROM cityPopulation WHERE interpolation = TRUE;")
dbGetQuery(dbConn, "DELETE FROM countryPopulation WHERE interpolation = TRUE;")


cityIDs <- dbGetQuery(dbConn, "SELECT cityID FROM cityPopulation group by cityID;")

end.year<- dbGetQuery(dbConn, "SELECT max(year) FROM cityPopulation;")
end_year<- as.numeric(end.year)
#print(end_year)

# #min number of data points needed to interpolate/extrapolate the data
min.data=2

for (i in 1:length(cityIDs[ ,1])) {
  #get the data for one city at a time
  cityID<-as.character(cityIDs[i, ])
  getdata1<- paste0("SELECT cityID, population, year FROM cityPopulation WHERE cityID=\"", cityID, "\" ;")
  my_data<-dbGetQuery(dbConn, getdata1) 
 # print(my_data)
  
  #get the year of the first observation
  getdata2<- paste0("SELECT min(year) FROM cityPopulation  WHERE cityID=\"", cityID, "\" ;")
  start.year <- dbGetQuery(dbConn, getdata2)
  start_year<- as.numeric(start.year)
  #print(start_year)

  #get the year of the first observation
  getdata3<- paste0("SELECT max(year) FROM cityPopulation  WHERE cityID=\"", cityID, "\" ;")
  end.year <- dbGetQuery(dbConn, getdata3)
  end_year<- as.numeric(end.year)
  #print(start_year)
  
  year<-seq(start_year, end_year)
  #create a data frame with the years and data needed for the intrapolation
  popul_data<-as.data.frame(year)
  inserts <- c()
  
  if (length(my_data$year) >= min.data) {
    #add column for population and city name
    popul_data$population<-NA
    popul_data$cityID<-my_data$cityID[1]
    #insert the data from the observations present
    popul_data$population[match(my_data$year, popul_data$year)]<-my_data$population
    #interpolate the data 
    popul_data$population<-na.spline(popul_data$population)
   # print(match(my_data$year, popul_data$year))
    import.data<-popul_data[-match(my_data$year, popul_data$year), ]
    #print(import.data)
  }

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


#----------------------------------------------------------------------
# Interpolating country population data
# ----------------------------------------------------------------------


countryIDs <- dbGetQuery(dbConn, "SELECT countryID FROM countryPopulation WHERE countryID != \"SK\" group by countryID;")

end.year<- dbGetQuery(dbConn, "SELECT max(year) FROM countryPopulation;")
end_year<- as.numeric(end.year)
#print(end_year)

# #min number of data points needed to interpolate/extrapolate the data
min.data=2

for (i in 1:length(countryIDs[ ,1])) {
  #get data for one country at a time
  countryID<-as.character(countryIDs[i, ])
  getdata1<- paste0("SELECT countryID, population, year FROM countryPopulation WHERE countryID=\"", countryID, "\" ;")
  my_data<-dbGetQuery(dbConn, getdata1) 
 # print(my_data)
  
  #get data about the year of the first observation
  getdata2<- paste0("SELECT min(year) FROM countryPopulation  WHERE countryID=\"", countryID, "\" ;")
  start.year <- dbGetQuery(dbConn, getdata2)
  start_year<- as.numeric(start.year)
  #print(start_year)
  
  #get the year of the last observation
  getdata3<- paste0("SELECT max(year) FROM countryPopulation  WHERE countryID=\"", countryID, "\" ;")
  end.year <- dbGetQuery(dbConn, getdata3)
  end_year<- as.numeric(end.year)
  #print(end_year)
  
#create a data frame with the years and data needed fo the interpolation
  year<-seq(start_year, end_year)
  popul_data<-as.data.frame(year)
  inserts <- c()
  if (length(my_data$year) >= min.data) {
    
    #add column for population and city name
    popul_data$population<-NA
    popul_data$countryID<-my_data$countryID[1]
    #insert the data from the observations present
    popul_data$population[match(my_data$year, popul_data$year)]<-my_data$population
    #interpolate the data 
    popul_data$population<-na.spline(popul_data$population)
    #print(match(my_data$year, popul_data$year))
    import.data<-popul_data[-match(my_data$year, popul_data$year), ]
    #print(import.data)
  }

  if (nrow(import.data)>0) {
    for (j in 1:nrow(import.data)){
     
      inserts <- c(inserts, paste0("(\"", import.data$countryID[j], "\",", import.data$year[j] , ",", import.data$population[j], ", true )"))
      
    }
  }
  
  if (length(inserts) > 0) {
    query <- paste("INSERT INTO countryPopulation",
                   "(countryID, year, population, interpolation)",
                   "VALUES", paste(inserts,collapse = ", "))
    dbGetQuery(dbConn, query)
  }
}








