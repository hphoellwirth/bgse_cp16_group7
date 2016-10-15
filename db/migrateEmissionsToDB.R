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

# load libraries
library("RMySQL")

# if interactive, during the development, set to TRUE
interactive <- TRUE
if (interactive) {
    setwd("/Users/Hans-Peter/Documents/Masters/14D003/project")
    loadFileName <- "data/CLRTAP_NFR14_V16_GF.csv"
} 

# load data
#dat <- read.csv(loadFileName, header = TRUE, sep = "", nrows=100)


# ----------------------------------------------------------------------
# Connect to mySQL database
# ----------------------------------------------------------------------
#system('ssh -i "../14D003.pem" ubuntu@54.171.170.201 -N sleep 20'')
db = dbConnect(MySQL(), 
               host='0.0.0.0', port=3306,
               user='gseuser', password='gsepass', 
               dbname='airpollution')





