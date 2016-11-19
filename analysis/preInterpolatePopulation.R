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

start.year <- dbGetQuery(dbConn, "SELECT min(year) FROM cityPopulation;")
end.year<- dbGetQuery(dbConn, "SELECT max(year) FROM cityPopulation;")
start_year<- as.numeric(start.year)
end_year<- as.numeric(end.year)

for (i in 1:length(cityIDs[ ,1])){
    
    # run regression on existing population data
    cityID<-as.character(cityIDs[i, ])
    getdata<- paste0("SELECT cityID, population, year FROM cityPopulation WHERE cityID=\"", cityID, "\" ;")
    my_data<-dbGetQuery(dbConn, getdata)
    year<-my_data$year
    # TBD: only run if at least 2 data points exist
    population<-my_data$population
    # TBD: regression probably not the right way here - probably better to draw linear lines between data points
    regression<-lm(population~year)
    
    # insert interpolated data points
    inserts <- c()
    for (y in start_year:end_year){
        if (is.element(y, year)==FALSE) {
            predicted.population<-predict(regression, data.frame(year=y))
            predicted.population<-round(as.numeric(as.data.frame(predicted.population)[1,1]))
            inserts <- c(inserts, paste0("(\"", cityID, "\",", y , ",", predicted.population, ", true )"))
        }
    }
    if (length(inserts) > 0) {
        query <- paste("INSERT INTO cityPopulation",
                       "(cityID, year, population, interpolation)",
                       "VALUES", paste(inserts,collapse = ", "))
        invisible(dbGetQuery(dbConn, query))
    }
}

