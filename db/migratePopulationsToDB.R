# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Add annual city and country population data to database
#
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Loading population data
# ----------------------------------------------------------------------

# house cleaning
rm(list = ls())

# install/load libraries
suppressMessages(if(!require(openxlsx)){install.packages("openxlsx")})
suppressMessages(if(!require(RMySQL)){install.packages("RMySQL")})
suppressMessages(if(!require(mgcv)){install.packages("mgcv")})

suppressMessages(library(openxlsx))
suppressMessages(library(RMySQL))
suppressMessages(library(mgcv))

# if interactive, during the development, set to TRUE
interactive <- FALSE
if (interactive) {
    setwd("/Users/Hans-Peter/Documents/Masters/14D003/project")
} 
loadFileName <- "data/urb_cpop1.xlsx"

# load data
dat  <- read.xlsx(loadFileName, sheet = 1, rows = seq(9,1014), colNames = TRUE)

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
# Process country population
# ----------------------------------------------------------------------
dat_ctry <- dat[nchar(dat$City) == 2,]

countries <- dbGetQuery(dbConn, "SELECT countryId FROM country;")

for (i in 1:dim(countries)[1]) {
    for (year in 1990:2015) {
        country <- as.character(countries[i,])
        value <- dat_ctry[dat_ctry$City == country, ][year-1990+2]
        
        if (dim(value)[1] == 1 && value != ":") {
            population <- as.numeric(value)
            
            query <- paste0("INSERT INTO countryPopulation ",
                            "(countryID, year, population) ", 
                            "VALUES (\"", country, "\",", year, ",", population, ");")
            invisible(dbGetQuery(dbConn, query))
        }
    }
}

# ----------------------------------------------------------------------
# Process city population
# ----------------------------------------------------------------------
dat_city <- dat[nchar(dat$City) == 7,]

cities <- dbGetQuery(dbConn, "SELECT cityId FROM city;")

for (i in 1:dim(cities)[1]) {
    for (year in 1990:2015) {
        city <- as.character(cities[i,])
        value <- dat_city[dat_city$City == city, ][year-1990+2]
        
        if (dim(value)[1] == 1 && value != ":") {
            population <- as.numeric(value)
            
            query <- paste0("INSERT INTO cityPopulation ",
                           "(cityID, year, population) ", 
                           "VALUES (\"", city, "\",", year, ",", population, ");")
            invisible(dbGetQuery(dbConn, query))
        }
    }
}

