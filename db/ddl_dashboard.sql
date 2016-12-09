# -------------------------------------------
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
# -------------------------------------------

use airpollution;

/************************/
/* Create geo map views */
/************************/ 

-- view for geo map of city concentrations
create view cityGeoMap as
  select cityId, cityName, latitude, longitude, year, pollutantID, concentration
    from cityConcentration
   where latitude is not null
     and longitude is not null
     and cityName not rlike '[^\x00-\x7F]'; -- TBD: replace unicode characters with new function

-- obsolete      
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

-- obsolete
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



/*********************************/
/* Create data descriptive views */
/*********************************/ 

-- view annual national concentration level averages    
create view concentrationView as
  select countryID,
         pollutantID,
         year,
         concentration,
         (select limitConc 
            from pollutant p 
           where p.pollutantID = n.pollutantID) as cLimit,          
         (select concentration
            from cityConcentration c, largestCities l
           where l.countryID   = n.countryID
             and c.pollutantID = n.pollutantID
             and c.year        = n.year
             and c.cityID      = l.cityID
             and l.rank        = 1) as concCityR1,
         (select concentration
            from cityConcentration c, largestCities l
           where l.countryID   = n.countryID
             and c.pollutantID = n.pollutantID
             and c.year        = n.year
             and c.cityID      = l.cityID
             and l.rank        = 2) as concCityR2,
         (select concentration
            from cityConcentration c, largestCities l
           where l.countryID   = n.countryID
             and c.pollutantID = n.pollutantID
             and c.year        = n.year
             and c.cityID      = l.cityID
             and l.rank        = 3) as concCityR3                          
    from countryConcentration n
   group by countryID, pollutantID, year;

-- view on percentage of stations exceeding limit on average in a year
create view excStationView as   
  select countryID, pollutantID, year,
         (case when totStations = 0 then 0 else (excStations/totStations) end) as pctExcStations,
         (select (case when c.totStations = 0 then 0 else (c.excStations/c.totStations) end)
            from cityConcentration c, largestCities l
           where l.countryID   = n.countryID
             and c.pollutantID = n.pollutantID
             and c.year        = n.year
             and c.cityID      = l.cityID
             and l.rank        = 1) as pctExcCityR1,
         (select (case when c.totStations = 0 then 0 else (c.excStations/c.totStations) end)
            from cityConcentration c, largestCities l
           where l.countryID   = n.countryID
             and c.pollutantID = n.pollutantID
             and c.year        = n.year
             and c.cityID      = l.cityID
             and l.rank        = 2) as pctExcCityR2,
         (select (case when c.totStations = 0 then 0 else (c.excStations/c.totStations) end)
            from cityConcentration c, largestCities l
           where l.countryID   = n.countryID
             and c.pollutantID = n.pollutantID
             and c.year        = n.year
             and c.cityID      = l.cityID
             and l.rank        = 3) as pctExcCityR3                                      
    from countryConcentration n; 

-- view on annual national total and particular sector emissions   
create view emissionView as
  select countryID, pollutantID, year,
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

-- view on national and countries' largest cities population    
create view populationView as
  select countryID, year, population,
         (select population
            from cityPopulation c, largestCities l
           where l.countryID = p.countryID
             and c.year      = p.year
             and c.cityID    = l.cityID
             and l.rank      = 1) as popCityR1,
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

   
   
   
   
   
   
   
   
   
