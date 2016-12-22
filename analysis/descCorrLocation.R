# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Descriptive analysis: Correlation of city location (longitude/latitude)
#                       with pollution concentration level
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
invisible(dbGetQuery(dbConn, "DELETE FROM correlationLocation"))

# ----------------------------------------------------------------------
# Regression functions
# ----------------------------------------------------------------------
range01 <- function(x){(x-min(x))/(max(x)-min(x))}

regression.values <- function(data, pollutant, year) {
    dat <- data
    
    # select country and pollutant
    dat <- dat[dat$pollutantID == pollutant,]
    dat <- dat[dat$year == year,]
    
    # remove non-factors from data frame
    use <- c("concentration","longitude",'latitude')
    dat <- dat[ , (names(dat) %in% use)]
    dat <- dat[complete.cases(dat),]
    #dat$longitude <- range01(dat$longitude)
    #dat$latitude <- range01(dat$latitude)

    if (nrow(dat) < 2 | ncol(dat) == 0) 
        return(list())
    else {
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

first.row <- TRUE
for (p in 1:length(pollutants)){
    pollutant <- as.character(pollutants[p])
    for (year in 1985:2013) {
        result <- regression.values(data, pollutant, year)
        if(length(result) > 0) {
            if (result$r.squared > 0 & result$r.squared < 1) {
                intercept.est   <- result$coefficients[1,1]
                intercept.se    <- result$coefficients[1,2]
                intercept.tval  <- result$coefficients[1,3]
                longitude.est   <- result$coefficients[2,1]
                longitude.se    <- result$coefficients[2,2]
                longitude.tval  <- result$coefficients[2,3]
                latitude.est    <- result$coefficients[3,1]
                latitude.se     <- result$coefficients[3,2]
                latitude.tval   <- result$coefficients[3,3]
                r.squared       <- result$r.squared
                
                # only store results if statistically significant
                # at 95% confidence level
                longitude.sig <- abs(longitude.tval) > 1.96 
                latitude.sig <- abs(latitude.tval) > 1.96 
                
                if (abs(intercept.tval) > 1.96 & (longitude.sig | latitude.sig)) {
    
                    new.row <- data.frame(pollutant, year, 
                                          intercept.est, intercept.se, 
                                          longitude.est, longitude.se, as.integer(longitude.sig),
                                          latitude.est, latitude.se, as.integer(latitude.sig),
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


# ----------------------------------------------------------------------
# Store correlations in database
# ----------------------------------------------------------------------
inserts <- paste0("(\"", apply(table.corr, 1, paste0, collapse = "\", \""), "\")")
query <- paste("INSERT INTO correlationLocation",
               "(pollutantID, year, interceptEst, interceptSE, longitudeEst, longitudeSE, longitudeSig, latitudeEst, latitudeSE, latitudeSig, rSquared)",
               "VALUES", paste(inserts,collapse = ", "))
#print(query)
invisible(dbGetQuery(dbConn, query))

# reactivate warnings
options(warn=0)

