# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Descriptive analysis: Correlation of population of city population
#                       size to pollution concentration level
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

# deactivate warnings
options(warn=-1)

# ----------------------------------------------------------------------
# Loading data (for client-side tests only)
# ----------------------------------------------------------------------
interactive <- FALSE
if (interactive) {
    setwd("/Users/Hans-Peter/Documents/Masters/14D003/project")
    loadFileName <- "analysis/data/cityConcentration.csv"
    data <- read.csv2(loadFileName,header = TRUE, sep = ",", dec = ".",
                     na.string="NULL", stringsAsFactors = FALSE)
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
# Delete existing correlations
# ----------------------------------------------------------------------
invisible(dbGetQuery(dbConn, "DELETE FROM correlationPopulation"))

# ----------------------------------------------------------------------
# Regression functions
# ----------------------------------------------------------------------
regression.values <- function(data, pollutant, country, year) {
    dat <- data
    
    # select country and pollutant
    dat <- dat[dat$pollutantID == pollutant,]
    dat <- dat[dat$countryID == country,]
    dat <- dat[dat$year == year,]
    
    # remove non-factors from data frame
    use <- c("concentration","population")
    dat <- dat[ , (names(dat) %in% use)]
    dat <- dat[complete.cases(dat),]

    if (nrow(dat) < 2 | ncol(dat) == 0) 
        return(list())
    else {
        # scale values to mean 0 and sd 1
        #dat[, -c(1)] <- scale(dat[, -c(1)])
        #dat <- dat[,colSums(is.na(dat)) == 0]  
            
        # linear regression
        fit <- lm(concentration ~ ., data = dat)
        out <- summary(fit)
        return(out)
    }
}

#result <- regression.values(data, "PM10", "TR", 2008)

# ----------------------------------------------------------------------
# Run regression
# ----------------------------------------------------------------------
data <- dbGetQuery(dbConn, "SELECT * FROM cityConcentration;")
pollutants <- c("PM10","NO2","O3", "PM2.5", "BaP")
countries <- dbGetQuery(dbConn, "SELECT countryID FROM country;")

first.row <- TRUE
for (p in 1:length(pollutants)){
    pollutant <- as.character(pollutants[p])
    for (c in 1:dim(countries)[1])  {
        for (year in 1985:2013) {
            country <- as.character(countries[c,])
            
            result <- regression.values(data, pollutant, country, year)
            if(length(result) > 0) {
                if (result$r.squared > 0 & result$r.squared < 1) {
                    intercept.est   <- result$coefficients[1,1]
                    intercept.se    <- result$coefficients[1,2]
                    intercept.tval  <- result$coefficients[1,3]
                    slope.est       <- result$coefficients[2,1]
                    slope.se        <- result$coefficients[2,2]
                    slope.tval      <- result$coefficients[2,3]
                    r.squared       <- result$r.squared
                    
                    # only store results if statistically significant
                    # at 95% confidence level
                    if (abs(intercept.tval) > 1.96 & abs(slope.tval) > 1.96) {
                        new.row <- data.frame(pollutant, country, year, 
                                              intercept.est, intercept.se, 
                                              slope.est, slope.se, 
                                              r.squared) 
                        if (first.row) {
                            table.corr <- new.row
                            first.row <- FALSE
                        }
                        else
                            table.corr <- rbind(table.corr, new.row)             
                    }
                }
            }
        }
    }
}


# ----------------------------------------------------------------------
# Store correlations in database
# ----------------------------------------------------------------------
inserts <- paste0("(\"", apply(table.corr, 1, paste0, collapse = "\", \""), "\")")
query <- paste("INSERT INTO correlationPopulation",
               "(pollutantID, countryID, year, interceptEst, interceptSE, slopeEst, slopeSE, rSquared)",
               "VALUES", paste(inserts,collapse = ", "))
#print(query)
invisible(dbGetQuery(dbConn, query))

# reactivate warnings
options(warn=0)

