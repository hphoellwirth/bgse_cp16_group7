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
# Prepare/pre-filter data
# ----------------------------------------------------------------------
dat$Emissions[dat$Emissions == ''] <- 0 
dat$Emissions <- as.numeric(dat$Emissions)
dat$Pollutant_name[dat$Pollutant_name == "NOx"] <- "NO2" 

# filter only nonzero values
dat <- dat[!(dat$Sector_code %in% c("ADJUSTMENTS (Net total)",
                                    "NATIONAL TOTAL",
                                    "NATIONAL TOTAL FOR COMPLIANCE")),]
dat <- dat[!(dat$Country_code %in% c("AL", "BA", "LI", "MK", "ME", "RS", "")),]
dat <- dat[dat$Emissions > 0,]


# ----------------------------------------------------------------------
# Insert sectors
# ----------------------------------------------------------------------
sectors <- uniquecombs(data.frame(code = paste0("\"",dat$Sector_code,"\""),
                                  name = paste0("\"",dat$Sector_name,"\"")))
inserts <- apply(sectors, 1, paste, collapse = ", ")
query <- paste("INSERT INTO sector",
               "(sectorID, sectorName)",
               "VALUES (", paste(inserts, collapse = "), ("), ");")
invisible(dbGetQuery(dbConn, query))



# ----------------------------------------------------------------------
# Insert emissions (of selected pollutant types)
# ----------------------------------------------------------------------
pollutants <- c("PM10","PM2.5","NO2")
for (i in 1:length(pollutants)) {
    dat_pol <- dat[dat$Pollutant_name == pollutants[i],] 
    
    emission <- data.frame(code = paste0("\"",dat_pol$Pollutant_name,"\""),
                           country = paste0("\"",dat_pol$Country_code,"\""),
                           sector = paste0("\"",dat_pol$Sector_code,"\""),
                           year = dat_pol$Year,
                           emission = paste0("\"",dat_pol$Emissions,"\""))
    inserts <- paste("(", apply(emission, 1, paste, collapse = ", "), ")")
    query <- paste("INSERT INTO emission",
                   "(pollutantID, countryID, sectorID, year, emission)",
                   "VALUES ", paste(inserts,collapse = ", "))   
    invisible(dbGetQuery(dbConn, query))
}
