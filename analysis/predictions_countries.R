#Changing wd
setwd('/home/cirp/Documents/Data science master/App project/repository/analysis/data')

#Importing data
mydata = read.csv('countryConcentration.csv',sep = ',',stringsAsFactors = FALSE,na.strings = 'NULL')
library(forecast)


#Calculating ARIMA models for each combination of country and pollutant
k = 0
first = 0
model = list()
predictions = list()
lab = matrix(NA,160,2)
for (j in levels(as.factor(mydata$countryID))){
  for (i in levels(as.factor(mydata$pollutantID))){
    k = k + 1
    mydata1=mydata[mydata$countryID==j & mydata$pollutantID==i,]
    mydata1=mydata1[order(mydata1$year),]
    lab[k,1] = j 
    lab[k,2] = i
    if (dim(mydata1)[1]>1){
      times = ts(mydata1$concentration,start=min(mydata1$year), end=max(mydata1$year)-1, frequency=1)
      model[[k]] = auto.arima(mydata1$concentration)
      if (length(model[[k]])>0){
        predictions[[k]] = forecast(model[[k]],5)
        first = first + 1
        prediction = as.numeric(predictions[[k]]$mean)
        country = matrix(j,length(prediction),1)
        pollutant = matrix(i,length(prediction),1)
        year = seq(max(mydata[mydata$countryID==j & mydata$pollutantID==i,'year'])+1,max(mydata[mydata$countryID==j & mydata$pollutantID==i,'year'])+5,1)
        low_95 = as.matrix(predictions[[k]]$lower[,2])
        up_95 = as.matrix(predictions[[k]]$upper[,2])
        temp = data.frame(country,pollutant,year,prediction,low_95,up_95)
        if (first==1){
          table_predictions = temp
        }
        else{
          table_predictions = rbind(table_predictions,temp)   
        }
      }
    }
  }
}


#Plots
  # par(ask = TRUE)
  # for (i in 1:length(model)){
  #   if (length(model[[i]])>0){
  #     plot(predictions[[i]])
  #   }
  # }
  # par(ask = FALSE)

#For the milestone
plot(predictions[[53]],main='Country=FI     Pollutant=O3',xaxt='n')
axis(1, at=1:29, labels=seq(1990,2018,1))

