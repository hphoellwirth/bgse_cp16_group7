# -------------------------------------------
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
# -------------------------------------------

use airpollution;

/************************/
/* Create table indexes */
/************************/
create index idx_concentration 
  on concentration (pollutantID, stationID, year);
  
create index idx_emission
  on emission (pollutantID, countryID, sectorID, year);  

create index idx_countryPopulation
  on countryPopulation (countryID, year);
  
create index idx_cityPopulation
  on cityPopulation (cityID, year);  
  
/* note: primary and foreign keys are automatically indexed */  


/****************/
/* Create views */
/****************/

-- concEvaluation
create view concEvaluation as
  select t.concID                                 as concID,
         t.pollutantID                            as pollutantID,
         t.stationID                              as stationID,
         t.year                                   as year,
         t.concentration                          as concentration,
         t.pctValid                               as pctValid,
         t.measurementCode                        as measurementCode,   
         t.population                             as population,
         if(t.concentration >= p.limitConc, 1, 0) as exceededLimit 
    from pollutant p, concentration t
   where p.pollutantID = t.pollutantID;   

-- countryConcentration
create view countryConcentration as
  select n.countryID          as countryID, 
         n.countryName        as countryName,
         e.pollutantID        as pollutantID, 
         e.year               as year, 
         count(s.stationID)   as noStations,
         sum(e.exceededLimit) as noExceededLimit,
         sum(e.population)    as stationPopulation,
         p.population         as population
    from country n,
         city c, 
         station s, 
         concEvaluation e,
         countryPopulation p
   where n.countryID = c.CountryID
     and c.cityID    = s.cityID
     and s.stationID = e.stationID
     and n.countryID = p.countryID
     and e.year      = p.year
   group by c.countryID, e.pollutantID, e.year;

-- cityConcentration
create view cityConcentration as
  select c.cityID             as cityID,
         c.cityName           as cityName, 
         e.pollutantID        as pollutantID, 
         e.year               as year, 
         count(s.stationID)   as stations, 
         sum(e.exceededLimit) as noExceededLimit,
         sum(e.population)    as population
    from city c,
         station s, 
         concEvaluation e
   where c.cityID = s.CityID
     and s.stationID = e.stationID
   group by s.cityID, e.pollutantID, e.year;
