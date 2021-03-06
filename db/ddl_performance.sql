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


/********************************/
/* Create general purpose views */
/********************************/

-- evaluated concentration levels
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

-- country concentration
create view countryConcentration as
  select n.countryID          as countryID, 
         n.countryName        as countryName,
         e.pollutantID        as pollutantID, 
         e.year               as year, 
         avg(e.concentration) as concentration,
         (select p.population
            from countryPopulation p
		       where p.countryID = n.countryID
             and p.year      = e.year) as population,
	       count(s.stationID)   as totStations,
         sum(e.exceededLimit) as excStations,
         sum(e.population)    as totStationsPop,
         sum(if(e.exceededLimit,e.population,0)) as excStationsPop
    from country n, 
         city c, 
         station s, 
         concEvaluation e
   where n.countryID = c.CountryID
     and c.cityID    = s.cityID
     and s.stationID = e.stationID
   group by c.countryID, e.pollutantID, e.year;
  
-- city concentration
create view cityConcentration as
  select c.cityID             as cityID,
         c.cityName           as cityName, 
         c.countryID          as countryID,
         c.longitude          as longitude,
         c.latitude           as latitude,
         e.pollutantID        as pollutantID, 
         e.year               as year, 
         avg(e.concentration) as concentration,
         count(s.stationID)   as totStations, 
         sum(e.exceededLimit) as excStations,
         sum(e.population)    as totStationsPop,
         (select p.population
            from cityPopulation p
		       where p.cityID = c.cityID
             and p.year   = e.year) as population         
    from city c,
         station s, 
         concEvaluation e
   where c.cityID = s.CityID
     and s.stationID = e.stationID
   group by s.cityID, e.pollutantID, e.year;

-- country emissions (annual national total and sector emissions)  
create view countryEmission as
  select countryID, 
         pollutantID, 
         year,
         sum(emission) as emission,
         sum(case when parentID = '11' then emission else 0 end) as emission11,
         sum(case when parentID = '1A1' then emission else 0 end) as emission1A1,
         sum(case when parentID = '1A2' then emission else 0 end) as emission1A2,
         sum(case when parentID = '1A3' then emission else 0 end) as emission1A3,
         sum(case when parentID = '1Ax' then emission else 0 end) as emission1Ax,
         sum(case when parentID = '1B' then emission else 0 end) as emission1B,
         sum(case when parentID = '2' then emission else 0 end) as emission2,
         sum(case when parentID = '3' then emission else 0 end) as emission3,
         sum(case when parentID = '5' then emission else 0 end) as emission5
    from emission e, sector s
   where e.sectorID = s.sectorID
   group by countryID, pollutantID, year;  

   
   
   
   
   
   
   
   
