# -------------------------------------------
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
# -------------------------------------------

use airpollution;

drop view if exists stationDetail;
drop view if exists addedStationImpactView;
drop view if exists countryConcAndEmission;
drop view if exists countryPollutantFactor;
drop view if exists concForecastEvaluation;
drop view if exists countryConcentrationStationForecast;
drop view if exists concentrationStationForecastView;
drop view if exists excStationForecastView;
drop view if exists concentrationCountryForecastView;

/*************************************/
/* Create descriptive analysis views */
/*************************************/

-- stationDetail
create view stationDetail as
  select stationID, cityID, stationType, areaType,
         (select min(year)
            from concentration c
           where c.stationID = s.stationID) as startYear
    from station s; 
   
-- addedStationImpactView
create view addedStationImpactView as
  select countryID,
         pollutantID,
         year,
         concentration as concAll,
         (select avg(concentration)
            from city c, stationDetail s, concentration e
           where c.countryID   = n.CountryID
             and c.cityID      = s.cityID
             and e.stationID   = s.stationID
             and e.pollutantID = n.pollutantID
             and e.year        = n.year
             and s.startYear  <= 2005) as conc2005Stations,
         (select avg(concentration)
            from city c, stationDetail s, concentration e
           where c.countryID   = n.CountryID
             and c.cityID      = s.cityID
             and e.stationID   = s.stationID
             and e.pollutantID = n.pollutantID
             and e.year        = n.year
             and s.startYear  <= 2000) as conc2000Stations,
         (select limitConc 
            from pollutant p 
           where p.pollutantID = n.pollutantID) as cLimit                            
    from countryConcentration n;    
   
   
/************************************/
/* Create regression analysis views */
/************************************/

-- combine annual national concentration and sector emission levels
create view countryConcAndEmission as
  select c.countryID,
         c.countryName,
         c.pollutantID,
         c.year,
         c.population,
         c.concentration,
         e.emission11,
         e.emission1A1, 
         e.emission1A2, 
         e.emission1A3, 
         e.emission1Ax, 
         e.emission1B, 
         e.emission2, 
         e.emission3, 
         e.emission5       
    from countryConcentration c, countryEmission e
   where c.countryID   = e.countryID
     and c.pollutantID = e.pollutantID
     and c.year        = e.year;


/*****************************************/
/* Create post-regression forecast views */
/*****************************************/

-- concentration forecast evaluation (station level)
create view concForecastEvaluation as
  select t.forecastID                             as forecastID,
         t.pollutantID                            as pollutantID,
         t.stationID                              as stationID,
         t.year                                   as year,
         t.concentration                          as concentration,
         t.low95                                  as low95,
         t.high95                                 as high95,
         if(t.concentration >= p.limitConc, 1, 0) as meanExcLimit,
         if(t.low95 >= p.limitConc, 1, 0)         as low95ExcLimit,
         if(t.high95 >= p.limitConc, 1, 0)        as high95ExcLimit
    from pollutant p, forecastStationConcentration t
   where p.pollutantID = t.pollutantID;   

-- countryConcentrationForecast
create view countryConcentrationStationForecast as
  select n.countryID           as countryID, 
         n.countryName         as countryName,
         f.pollutantID         as pollutantID, 
         f.year                as year, 
         avg(f.concentration)  as concentration,
         avg(f.low95)          as low95,
         avg(f.high95)         as high95,
         count(s.stationID)    as totStations,
         sum(f.meanExcLimit)   as excStations,
         sum(f.low95ExcLimit)  as excStationsLow95,
         sum(f.high95ExcLimit) as excStationsHigh95
    from country n, 
         city c, 
         station s, 
         concForecastEvaluation f
   where n.countryID = c.CountryID
     and c.cityID    = s.cityID
     and s.stationID = f.stationID
     and f.year     >= 2014
   group by c.countryID, f.pollutantID, f.year; 

   
/**************************/
/* Create dashboard views */
/**************************/ 

-- view annual country concentrations including forecasts until 2018  
create view concentrationStationForecastView as
  select countryID,
         pollutantID,
         year,
         concentration,
         (select limitConc 
            from pollutant p 
           where p.pollutantID = n.pollutantID) as cLimit,          
         concentration as low95,
         concentration as high95                       
    from countryConcentration n
   group by countryID, pollutantID, year
   union
  select countryID,
         pollutantID,
         year,
         concentration,
         (select limitConc 
            from pollutant p 
           where p.pollutantID = f.pollutantID) as cLimit,          
         low95,
         high95                       
    from countryConcentrationStationForecast f
   group by countryID, pollutantID, year;
   
-- view on percentage of stations exceeding limit on average in a year   
create view excStationForecastView as   
  select countryID, 
         pollutantID, 
         year,
         (case when totStations = 0 then 0 else (excStations/totStations) end) as pctExcStations,  
         (case when totStations = 0 then 0 else (excStations/totStations) end) as pctExcStationsLow95, 
         (case when totStations = 0 then 0 else (excStations/totStations) end) as pctExcStationsHigh95                                    
    from countryConcentration n   
   union
  select countryID, 
         pollutantID, 
         year,
         (case when totStations = 0 then 0 else (excStations/totStations) end) as pctExcStations,
         (case when totStations = 0 then 0 else (excStationsLow95/totStations) end) as pctExcStationsLow95, 
         (case when totStations = 0 then 0 else (excStationsHigh95/totStations) end) as pctExcStationsHigh95                                                 
    from countryConcentrationStationForecast n;     
   
-- view annual country concentrations including forecasts until 2018  
create view concentrationCountryForecastView as
  select countryID,
         pollutantID,
         year,
         concentration,
         (select limitConc 
            from pollutant p 
           where p.pollutantID = n.pollutantID) as cLimit,          
         concentration as low95,
         concentration as high95                       
    from countryConcentration n
   group by countryID, pollutantID, year
   union
  select countryID,
         pollutantID,
         year,
         concentration,
         (select limitConc 
            from pollutant p 
           where p.pollutantID = f.pollutantID) as cLimit,          
         low95,
         high95                       
    from forecastCountryConcentration f
   group by countryID, pollutantID, year;      
      
   
