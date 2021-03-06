# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Descriptive analysis: Correlation of sector emissions
#                       on national pollutant concentration means
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
suppressMessages(if(!require(glmnet)){install.packages("glmnet")})

suppressMessages(library("RMySQL")) 
suppressMessages(library("glmnet")) 


# ----------------------------------------------------------------------
# Loading data (for client-side tests only)
# ----------------------------------------------------------------------
interactive <- FALSE
if (interactive) {
    setwd("/Users/Hans-Peter/Documents/Masters/14D003/project")
    loadFileName <- "analysis/data/countryConcAndEmission.csv"
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
# Regression functions
# ----------------------------------------------------------------------
regression.values <- function(pollutant, country) {
    dat <- data
    
    # select country and pollutant
    dat <- dat[dat$pollutantID == pollutant,]
    dat <- dat[dat$countryID == country,]
    
    # remove non-factors from data frame
    drops <- c("countryID","countryName", "pollutantID", "year","population")
    dat <- dat[ , !(names(dat) %in% drops)]
    
    # remove columns with all NAs
    dat <- dat[,colSums(is.na(dat)) == 0]    

    if (nrow(dat) == 0 | ncol(dat) == 0) 
        return(0)
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

regression.changes <- function(pollutant, country) {
    dat <- data
    
    # select country and pollutant
    dat <- dat[dat$pollutantID == pollutant,]
    dat <- dat[dat$countryID == country,]
    
    # remove non-factors from data frame
    drops <- c("countryID","countryName", "pollutantID", "population")
    dat <- dat[ , !(names(dat) %in% drops)]
    
    # remove columns with all NAs
    dat <- dat[,colSums(is.na(dat)) == 0]
    
    # scale values to mean 0 and sd 1
    dat[, -c(1)] <- scale(dat[, -c(1)])
    dat <- dat[,colSums(is.na(dat)) == 0] 
    
    # compute annual changes
    dat <- dat[order(-dat$year),]
    
    # compute annual differences
    diff <- dat[-1,]
    for (i in 2:nrow(dat)) {
        diff[i-1,] <- dat[i-1,] - dat[i,]
    }
    diff <- diff[ , !(names(diff) %in% c("year"))]    
    
    # linear regression
    fit <- lm(concentration ~ ., data = diff)
    out <- summary(fit)
    return(out)
}

regression.values("NO2", "CH")
regression.changes("NO2", "GR")

# ----------------------------------------------------------------------
# Regression on country pollutant concentration
# ----------------------------------------------------------------------
#dat <- dbGetQuery(dbConn, "SELECT * FROM countryPollutantFactor WHERE pollutantID = 'PM10' AND countryID = 'AT';")
dat <- data

# filter country and pollutant
dat <- dat[dat$pollutantID == 'PM10',]
dat <- dat[dat$countryID == 'GR',]

# remove non-factors from data frame
drops <- c("countryID","countryName", "pollutantID", "year","population")
dat <- dat[ , !(names(dat) %in% drops)]

# remove columns with all NAs
#dat <- dat[,colSums(is.na(dat))<nrow(dat)]
dat <- dat[,colSums(is.na(dat)) == 0]


# ----------------------------------------------------------------------
# Variable selection (using LASSO)
# ----------------------------------------------------------------------
X <- as.matrix(dat[ , names(dat) != 'concentration'])
#X <- apply(X, 2, as.numeric)
t <- as.vector(dat$concentration)
#t <- as.numeric(as.vector(dat$concentration))

glmmod <- glmnet(X,t,alpha=1,family="gaussian")
glmmod

# trace plot 
plot(glmmod,xvar="lambda")
grid()

# cross-validation to finde best lambda
cv.glmmod <- cv.glmnet(X,t,alpha=1,grouped=FALSE)
plot(cv.glmmod)
best_lambda <- cv.glmmod$lambda.min

coef(glmmod)[,25]


# ----------------------------------------------------------------------
# Linear regression with selected variables
# ----------------------------------------------------------------------
reg <- dat[ , (names(dat) %in% c("concentration","e1B1a"))] # AT/PM10
reg <- dat[ , (names(dat) %in% c("concentration","e1A1c","e1A3ai_i","e3B3","e5C1a"))] # BE/PM10
reg <- dat[ , (names(dat) %in% c("concentration","e11B","e11A1a","e3Dc","e5C1bv"))] # DE/PM10

reg <- dat[ , (names(dat) %in% c("concentration","e1A3bi","e1A3bii","e1A3biii","e1A3biv"))] # DE/PM10

reg <- dat
fit <- lm(concentration ~ ., data = reg)
out <- summary(fit)
print(out)


# ----------------------------------------------------------------------
# Compute correlations of differences
# ----------------------------------------------------------------------
dat <- data

# filter country and pollutant
dat <- dat[dat$pollutantID == 'PM10',]
dat <- dat[dat$countryID == 'FR',]

# remove non-factors from data frame
drops <- c("countryID","countryName", "pollutantID","population")
dat <- dat[ , !(names(dat) %in% drops)]

# remove columns with all NAs
dat <- dat[,colSums(is.na(dat)) == 0]

# compute annual changes
dat <- dat[order(-dat$year),]

# compute annual differences
diff <- dat[-1,]
for (i in 2:nrow(dat)) {
    diff[i-1,] <- dat[i-1,] - dat[i,]
}
diff <- diff[ , !(names(diff) %in% c("year"))]

# compute correlation between differences
corr <- cor(diff, diff$concentration, use = "complete")
corr

# regression
fit <- lm(concentration ~ ., data = diff)
out <- summary(fit)
print(out)
