# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Migrate emission data into database
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
suppressMessages(if(!require(RMySQL)){install.packages("RMySQL")})
suppressMessages(if(!require(mgcv)){install.packages("mgcv")})

suppressMessages(library("RMySQL"))
suppressMessages(library("mgcv"))

# if interactive, during the development, set to TRUE
interactive <- FALSE
if (interactive) {
    setwd("/Users/Hans-Peter/Documents/Masters/14D003/project")
}
loadFileName <- "data/CLRTAP_NFR14_V16_GF.csv"

# load data
dat <- read.csv2(loadFileName,header = TRUE, sep = "\t",stringsAsFactors = FALSE)
dat$Emissions[dat$Emissions==''] <-NA 
dat$Emissions <- as.numeric(dat$Emissions)


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
# Insert emissions
# ----------------------------------------------------------------------

# step 1: only filter relevant pollutants
#pollutants <- uniquecombs(data.frame(code = dat$Pollutant_name))

#dat_P10 <- dat[dat$Pollutant_name == 'PM10',]


# step 2: load sectors
# sectors <- uniquecombs(data.frame(code = dat$Sector_code,
#                                   name = dat$Sector_name,
#                                   parent = dat$Parent_sector_code))

# sectors <- uniquecombs(data.frame(code = paste0("\"",dat$Sector_code,"\""),
#                                   name = paste0("\"",dat$Sector_name,"\"")))
# inserts <- apply(sectors, 1, paste, collapse = ", ")
# query <- paste("INSERT INTO sector",
#                "(sectorID, sectorName)",
#                "VALUES (", paste(inserts, collapse = "), ("), ");")
# invisible(dbGetQuery(dbConn, query))



# step 3: load emission


# emission <- uniquecombs(data.frame(code = paste0("\"",dat$Pollutant_name,"\""),
#                                    country = paste0("\"",dat$Country_code,"\""),
#                                    sector = paste0("\"",dat$Sector_code,"\""),
#                                    year = paste0("\"",dat$Year,"\""),
#                                    emission = paste0("\"",dat$Emissions,"\"")))
# query <- paste("INSERT INTO emission",
#                "(emissionID, pollutantID, countryID, sectorID, year, emission)",
#                "VALUES (", apply(emission, 1, paste, collapse = ", "), ");")
# invisible(lapply(query, function(q) dbGetQuery(dbConn, q)))

# step 4: create manual inserts for parentID in dml_post_migration
