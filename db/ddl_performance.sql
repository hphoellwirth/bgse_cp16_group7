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
drop view if exists concEvaluation;
drop view if exists countryConcentration;
drop view if exists cityConcentration;
drop view if exists countryPollutantFactor;
drop view if exists countryConcentrations;
drop view if exists cityConcentrations;

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
  
-- cityConcentration
create view cityConcentration as
  select c.cityID             as cityID,
         c.cityName           as cityName, 
         c.countryID          as countryID,
         c.longitude          as longitude,
         c.latitude           as latitude,
         e.pollutantID        as pollutantID, 
         e.year               as year, 
         avg(e.concentration) as concentration,
         count(s.stationID)   as stations, 
         sum(e.exceededLimit) as noExceededLimit,
         sum(e.population)    as stationPopulation,
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
   
/************************************/
/* Create regression analysis views */
/************************************/
create view countryPollutantFactor as
  select c.countryID,
         c.countryName,
         c.pollutantID,
         c.year,
         c.population,
         c.concentration,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '11A') as e11A,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '11B') as e11B,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '11C') as e11C,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A1a') as e11A1a,               
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A1b') as e1A1b,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A1c') as e1A1c,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A2a') as e1A2a,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A2b') as e1A2b,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A2c') as e1A2c,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A2d') as e1A2d,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A2e') as e1A2e,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A2f') as e1A2f,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A2gvii') as e1A2gvii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A2gviii') as e1A2gviii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3ai(i)') as e1A3ai_i,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3ai(ii)') as e1A3ai_ii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3aii(i)') as e1A3aii_i,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3aii(ii)') as e1A3aii_ii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3bi') as e1A3bi,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3bii') as e1A3bii, 
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3biii') as e1A3biii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3biv') as e1A3biv,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3bv') as e1A3bv,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3bvi') as e1A3bvi,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3bvii') as e1A3bvii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3c') as e1A3c,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3di(i)') as e1A3di_i, 
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3di(ii)') as e1A3di_ii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3dii') as e1A3dii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3ei') as e1A3ei,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A3eii') as e1A3eii,               
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A4ai') as e1A4ai,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A4aii') as e1A4aii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A4bi') as e1A4bi,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A4bii') as e1A4bii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A4ci') as e1A4ci,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A4cii') as e1A4cii,        
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A4ciii') as e1A4ciii,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A5a') as e1A5a,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A5b') as e1A5b,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1A5c') as e1A5c,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1B1a') as e1B1a,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1B1b') as e1B1b,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1B1c') as e1B1c,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1B2ai') as e1B2ai,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1B2aiv') as e1B2aiv,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1B2av') as e1B2av,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1B2b') as e1B2b,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1B2c') as e1B2c,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '1B2d') as e1B2d,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2A1') as e2A1, 
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2A2') as e2A2,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2A3') as 32A3,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2A5a') as e2A5a,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2A5b') as e2A5b,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2A5c') as e2A5c,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2A6') as e2A6,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2B1') as e2B1, 
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2B2') as e2B2,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2B3') as e2B3,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2B5') as e2B5,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2B6') as e2B6,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2B7') as e2B7,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2B10a') as e2B10a,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2B10b') as e2B10b,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2C1') as e2C1, 
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2C2') as e2C2,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2C3') as e2C3,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2C4') as e2C4,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2C5') as e2C5,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2C6') as e2C6,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2C7a') as e2C7a,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2C7b') as e2C7b, 
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2C7c') as e2C7c,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2C7d') as e2C7d,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2D3a') as e2D3a,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2D3b') as e2D3b,               
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2D3c') as e2D3c,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2D3d') as e2D3d,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2D3e') as e2D3e,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2D3f') as e2D3f,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2D3g') as e2D3g,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2D3h') as e2D3h,        
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2D3i') as e2D3i,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2G') as e2G,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2H1') as e2H1,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2H2') as e2H2,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2H3') as e2H3,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2I') as e2I,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2K') as e2K,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '2L') as e2L,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B1a') as e3B1a,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B1b') as e3B1b,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B2') as e3B2,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B3') as e3B3,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B4a') as e3B4a,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B4d') as e3B4d, 
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B4e') as e3B4e,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B4f') as e3B4f,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B4gi') as e3B4gi,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B4gii') as e3B4gii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B4giii') as e3B4giii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B4giv') as e3B4giv,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3B4h') as e3B4h, 
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3Da1') as e3Da1,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3Da2a') as e3Da2a,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3Da2b') as e3Da2b,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3Da2c') as e3Da2c,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3Da3') as e3Da3,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3Da4') as e3Da4,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3Db') as e3Db,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3Dc') as e3Dc, 
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3Dd') as e3Dd,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3De') as e3De,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3Df') as e3Df,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3F') as e3F,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '3I') as e3I,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5A') as e5A,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5B1') as e5B1, 
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5B2') as e5B2,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5C1a') as e5C1a,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5C1bi') as e5C1bi,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5C1bii') as e5C1bii,               
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5C1biii') as e5C1biii,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5C1biv') as e5C1biv,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5C1bv') as e5C1bv,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5C1bvi') as e5C1bvi,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5C2') as e5C2,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5D1') as e5D1,        
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5D2') as e5D2,                                                                                         
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5D3') as e5D3,          
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '5E') as e5E,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '6A') as e6A,
         (select emission from emission e where e.countryID = c.countryID and e.pollutantID = c.pollutantID and e.year = c.year and e.sectorID = '6B') as e6B
    from countryConcentration c;

/**************************/
/* Create dashboard views */
/**************************/ 

-- view for geo map of city concentrations
create view cityGeoMap as
  select cityId, cityName, latitude, longitude, year, pollutantID, concentration
    from cityConcentration
   where latitude is not null
     and longitude is not null
     and cityName not rlike '[^\x00-\x7F]'; -- TBD: replace unicode characters with new function
      
create view countryConcentrations as
  select countryID,
         year,
         (select concentration from countryConcentration s where s.countryID = c.countryID and s.year = c.year and s.pollutantID = 'PM10') as cPM10,
         (select concentration from countryConcentration s where s.countryID = c.countryID and s.year = c.year and s.pollutantID = 'PM2.5') as cPM2_5,
         (select concentration from countryConcentration s where s.countryID = c.countryID and s.year = c.year and s.pollutantID = 'NO2') as cNO2,
         (select concentration from countryConcentration s where s.countryID = c.countryID and s.year = c.year and s.pollutantID = 'O3') as cO3,
         (select concentration from countryConcentration s where s.countryID = c.countryID and s.year = c.year and s.pollutantID = 'BaP') as cBaP,
         (select limitConc from pollutant where pollutantID = 'PM10') as lPM10, 
         (select limitConc from pollutant where pollutantID = 'PM2.5') as lPM2_5, 
         (select limitConc from pollutant where pollutantID = 'NO2') as lNO2, 
         (select limitConc from pollutant where pollutantID = 'O3') as lO3, 
         (select limitConc from pollutant where pollutantID = 'BaP') as lBaP 
    from countryConcentration c
   group by countryID, year;

create view cityConcentrations as
  select countryID,
         cityID,
         cityName,
         year,
         population,
         (select concentration from cityConcentration s where s.cityID = c.cityID and s.year = c.year and s.pollutantID = 'PM10') as cPM10,
         (select concentration from cityConcentration s where s.cityID = c.cityID and s.year = c.year and s.pollutantID = 'PM2.5') as cPM2_5,
         (select concentration from cityConcentration s where s.cityID = c.cityID and s.year = c.year and s.pollutantID = 'NO2') as cNO2,
         (select concentration from cityConcentration s where s.cityID = c.cityID and s.year = c.year and s.pollutantID = 'O3') as cO3,
         (select concentration from cityConcentration s where s.cityID = c.cityID and s.year = c.year and s.pollutantID = 'BaP') as cBaP 
    from cityConcentration c
   where cityID in (select l.cityID
                      from largestCities l
                     where l.countryID = c.countryID);

-- view on national and countries' largest cities population    
create view populationView as
  select countryID, year, population,
         (select cityName
            from city c, largestCities l
           where l.countryID = p.countryID
             and city.cityID = largestCities.cityID
             and l.rank      = 1) as R1CityName,
         (select population
            from cityPopulation c, largestCities l
           where l.countryID = p.countryID
             and c.year      = p.year
             and c.cityID    = l.cityID
             and l.rank      = 1) as R1CityPop,
         (select population
            from cityPopulation c, largestCities l
           where l.countryID = p.countryID
             and c.year      = p.year
             and c.cityID    = l.cityID
             and l.rank      = 2) as popCityR2,
         (select population
            from cityPopulation c, largestCities l
           where l.countryID = p.countryID
             and c.year      = p.year
             and c.cityID    = l.cityID
             and l.rank      = 3) as popCityR3
    from countryPopulation p;
   

