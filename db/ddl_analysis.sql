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
drop view if exists countryConcentrationForecast;
drop view if exists concentrationForecastView;

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
        
-- obsolete
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


/*****************************************/
/* Create post-regression forecast views */
/*****************************************/

-- concentration forecast evaluation
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
    from pollutant p, forecastConcentration t
   where p.pollutantID = t.pollutantID;   

-- countryConcentrationForecast
create view countryConcentrationForecast as
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
create view concentrationForecastView as
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
    from countryConcentrationForecast f
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
    from countryConcentrationForecast n;     
   
      
   
   
   
