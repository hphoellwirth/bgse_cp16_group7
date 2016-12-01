# -------------------------------------------
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
# -------------------------------------------

use airpollution;

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

-- view on annual national total and particular sector emissions   
create view emissionView as
  select countryID, pollutantID, year,
         sum(emission) as emission,
         sum(case when parentID = '11' then emission else 0 end) as emission11,
         sum(case when parentID = '1A3' then emission else 0 end) as emission1A3,
         sum(case when parentID = '1Ax' then emission else 0 end) as emission1Ax,
         sum(case when parentID = '1B' then emission else 0 end) as emission1B,
         sum(case when parentID = '2' then emission else 0 end) as emission2,
         sum(case when parentID = '3' then emission else 0 end) as emission3,
         sum(case when parentID = '5' then emission else 0 end) as emission5
    from emission e, sector s
   where e.sectorID = s.sectorID
   group by countryID, pollutantID, year;

-- view on percentage of stations exceeding limit on average in a year
create view excStationView as   
  select countryID, pollutantID, year,
         (case when totStations = 0 then 0 else (excStations/totStations) end) as pctExcStations
    from countryConcentration; 

-- view annual national concentration level averages    
create view concentrationView as
  select countryID,
         pollutantID,
         year,
         (select concentration from countryConcentration s where s.countryID = c.countryID and s.year = c.year and s.pollutantID = c.pollutantID) as concentration, 
         (select limitConc from pollutant p where p.pollutantID = c.pollutantID) as cLimit
    from countryConcentration c
   group by countryID, pollutantID, year;
   
   
   
   
   
   
   
   
   
