# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Add geo data (longitude & latitude) to database
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
loadFileName <- "data/world_cities.xlsx"

# load data
dat  <- read.xlsx(loadFileName, sheet = 1, startRow = 1, colNames = TRUE)

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
# Add geo data (latitude & longitude) to cities
# ----------------------------------------------------------------------
geo <- data.frame(ctry = paste0("\"",dat$iso2,"\""), 
                  city = paste0("\"",dat$city,"\""),
                  lng = dat$lng,
                  lat = dat$lat)

paste.query <- function(row) {
    x <- paste("UPDATE city",
          "SET longitude =", row$lng, ", latitude = ", row$lat,
          "WHERE countryID =", row$ctry, "AND cityName =", row$city, ";")
    return(x)
}

for (i in 1:dim(geo)[1])
    invisible(dbGetQuery(dbConn, paste.query(geo[i,])))

