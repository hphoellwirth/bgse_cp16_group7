# ----------------------------------------------------------------------
# Information
# ----------------------------------------------------------------------
#
# Descriptive analysis: Country pollutation factors
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
    loadFileName <- "analysis/data/countryPollutantFactor.csv"
    dat <- read.csv2(loadFileName,header = TRUE, sep = ",", dec = ".",
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

# ----------------------------------------------------------------------
# Regression on city pollutant concentration
# ----------------------------------------------------------------------
#dat <- dbGetQuery(dbConn, "SELECT * FROM countryPollutantFactor WHERE pollutantID = 'PM10' AND countryID = 'AT';")

# filter country and pollutant
dat <- dat[dat$pollutantID == 'PM10',]
dat <- dat[dat$countryID == 'DE',]

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

coef(glmmod)[,23]


# ----------------------------------------------------------------------
# Linear regression with selected variables
# ----------------------------------------------------------------------
reg <- dat[ , (names(dat) %in% c("concentration","e1B1a"))] # AT/PM10
reg <- dat[ , (names(dat) %in% c("concentration","e1A1c","e1A3ai_i","e3B3","e5C1a"))] # BE/PM10
reg <- dat[ , (names(dat) %in% c("concentration","e11A1a","e3Dc","e5C1bv"))] # DE/PM10

fit <- lm(concentration ~ ., data = reg)
out <- summary(fit)
print(out)
