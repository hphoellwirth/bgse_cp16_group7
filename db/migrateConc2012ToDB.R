# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Migrate pollution concentration data until 2012 into database
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

# load libraries
library("openxlsx")
library("RMySQL")

# if interactive, during the development, set to TRUE
interactive <- TRUE
if (interactive) {
    setwd("/Users/Hans-Peter/Documents/Masters/14D003/project")
    loadFileName <- "data/Air pollutant concentrations 2012 - Dataset complete.xlsx"
} 

# load data
dat_PM10  <- read.xlsx(loadFileName, sheet = 2, startRow = 11, colNames = TRUE)
dat_NO2   <- read.xlsx(loadFileName, sheet = 5, startRow = 11, colNames = TRUE)
dat_O3    <- read.xlsx(loadFileName, sheet = 8, startRow = 11, colNames = TRUE)
dat_PM2.5 <- read.xlsx(loadFileName, sheet = 11, startRow = 11, colNames = TRUE)
dat_BaP   <- read.xlsx(loadFileName, sheet = 14, startRow = 11, colNames = TRUE)

# ----------------------------------------------------------------------
# Connect to mySQL database
# ----------------------------------------------------------------------
#system('ssh -i "../14D003.pem" ubuntu@54.171.170.201 -N sleep 20'')
db = dbConnect(MySQL(), 
               host='0.0.0.0', port=3306,
               user='gseuser', password='gsepass', 
               dbname='airpollution')





