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
  
/* note: primary keys are automatically indexed */  

