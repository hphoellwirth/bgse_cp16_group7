# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Predictive analysis: Country pollutant concentration level
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
suppressMessages(if(!require(forecast)){install.packages("forecast")})

suppressMessages(library("RMySQL")) 
suppressMessages(library(forecast)) 

# deactivate warnings
options(warn=-1)

# ----------------------------------------------------------------------
# Loading data (for client-side tests only)
# ----------------------------------------------------------------------
interactive <- FALSE
if (interactive) {
    setwd("/Users/Hans-Peter/Documents/Masters/14D003/project")
    loadFileName <- "analysis/data/countryConcentration.csv"
    data <- read.csv2(loadFileName, sep = ',', 
                    stringsAsFactors = FALSE, na.strings = 'NULL')
} 

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
# Delete existing forecasts
# ----------------------------------------------------------------------
invisible(dbGetQuery(dbConn, "DELETE FROM forecastCountryConcentration"))

# ----------------------------------------------------------------------
# Loading data from database
# ----------------------------------------------------------------------
select <- "SELECT pollutantID, countryID, year, concentration FROM cityConcentration"
data <- invisible(dbGetQuery(dbConn, select));

# ----------------------------------------------------------------------
# Time-series prediction on station level
# ----------------------------------------------------------------------

# initialize
k <- 0
first.row <- TRUE
model <- list()
predictions <- list()

# calculate ARIMA models for each combination of station and pollutant
for (s in levels(as.factor(data$countryID))){
  #if (k == 10) break; # temporary stop condition    
  for (p in levels(as.factor(data$pollutantID))){
    k <- k + 1
    filt.data <- data[data$countryID==s & data$pollutantID==p,]
    filt.data <- filt.data[order(filt.data$year),]
    
    # only consider stations for which more than one data point exists
    if (dim(filt.data)[1] > 1){
        
      # compute ARIMA model for particular station and pollutant    
      times <- ts(filt.data$concentration, 
                  start = min(filt.data$year), 
                  end = max(filt.data$year) - 1, 
                  frequency = 1)
      model[[k]] <- auto.arima(as.numeric(filt.data$concentration))
      
      if (length(model[[k]]) > 0){
        # get forecasts until 2018
        no.years <- 2018 - max(data[data$countryID==s & data$pollutantID==p,'year'])  
        predictions[[k]] <- forecast(model[[k]],no.years)
        
        # setup new prediction
        prediction <- as.numeric(predictions[[k]]$mean)
        pollutant <- matrix(p,length(prediction),1)
        country <- matrix(s,length(prediction),1)
        year <- seq(max(data[data$countryID==s & data$pollutantID==p,'year']) + 1,
                   max(data[data$countryID==s & data$pollutantID==p,'year']) + no.years, 1)
        low_95 <- as.matrix(predictions[[k]]$lower[,2])
        up_95 <- as.matrix(predictions[[k]]$upper[,2])
        
        # avoid negative concentrations
        prediction[prediction < 0] <- 0
        low_95[low_95 < 0] <- 0
        up_95[up_95 < 0] <- 0
        
        # add new forecast to data frame
        new.row <- data.frame(pollutant, country, year, prediction, low_95, up_95)        
        if (first.row) {
          table_predictions <- new.row
          first.row <- FALSE
        }
        else
          table_predictions <- rbind(table_predictions, new.row)   
      }
    }
  }
}
#print(table_predictions)

# ----------------------------------------------------------------------
# Store forecasts in database
# ----------------------------------------------------------------------
inserts <- paste0("(\"", apply(table_predictions, 1, paste0, collapse = "\", \""), "\")")
query <- paste("INSERT INTO forecastCountryConcentration",
               "(pollutantID, countryID, year, concentration, low95, high95)",
               "VALUES", paste(inserts,collapse = ", "))
#print(query)
invisible(dbGetQuery(dbConn, query))


# ----------------------------------------------------------------------
# Create forecast plots
# ----------------------------------------------------------------------
# par(ask = TRUE)
# for (i in 1:length(model)){
#   if (length(model[[i]])>0){
#     plot(predictions[[i]])
#   }
# }
# par(ask = FALSE)

# reactivate warnings
options(warn=0)



