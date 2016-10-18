# -------------------------------------------
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
# -------------------------------------------

/*******************/
/* Create database */
/*******************/
drop database if exists airpollution;
create database airpollution;
use airpollution;

/*****************/
/* Create tables */
/*****************/
create table country (
  countryID    varchar(2),                   -- ISO 3166-1 alpha-2 code 
  countryName  varchar(40),                  -- English country name 
  pctTraffic   decimal(3,2),                -- fraction of population living close to traffic sources   
  
  primary key (countryID)
);

create table city (
  cityID     varchar(7),                     -- city code 
  cityName   varchar(40),                    -- English city name 
  countryID  varchar(2),                     -- reference to table country 
  popluation int (11),                       -- population in the Urban Audit core city 
  
  primary key (cityID)
);

create table station (
  stationID       varchar(7),                -- European station code 
  cityID          varchar(7),                -- reference to city table 
  stationType     varchar(11),               -- Dominant pollution source ("traffic" or "background") 
  areaType        varchar(8),                -- constructions around station ("urban" or "suburban") 
  
  primary key (stationID)
);

create table pollutant (
  pollutantID     varchar(5),                -- acronym of the pollutant 
  description     varchar(50),               -- pollutant name 
  statistic       varchar(5),                -- statistic (annual mean, percentile)
  unitConc        varchar(6),                -- measurement unit of concentration 
  unitEmission    varchar(20),               -- measurement unit of emission 
  limitDesc       varchar(100),              -- description of Europaean concentration limit 
  limitConc       decimal(5,2),              -- concentration limit 
  
  primary key (pollutantID)
);

create table concentration (
  concID          int(11) not null auto_increment, -- system ID 
  pollutantID     varchar(5),                      -- reference to pollutant table 
  stationID       varchar(7),                      -- reference to station table 
  year            int(4),                          -- statistics year 
  concentration   decimal(5,2),                    -- statistics value 
  pctValid        decimal(3,2),                    -- fraction of valid data in the year 
  measurementCode varchar(3),                      -- Type of technique used for measurement   
  popluation      int (11),                        -- population represented by station in that year   
  
  primary key (concID)
);
  
create table sector (
  sectorID      varchar(12),                       -- sector code   
  sectorName    varchar(100),                      -- sector name 
  parentID      varchar(12),                       -- parent sector code 
  treeLeaf      boolean,                           -- actual reporting level (Y/N) 
  
  primary key (sectorID)
);
  
create table emission (
  emissionID    int(11) not null auto_increment,   -- system ID 
  pollutantID   varchar(5),                        -- reference to pollutant table 
  countryID     varchar(2),                        -- reference to country table 
  sectorID      varchar(12),                       -- reference to sector table 
  year          int(4),                            -- statistics year 
  emission      decimal(10,2),                     -- statistics value in   
  
  primary key (emissionID)
);
  
/***********************/
/* Create foreign keys */
/***********************/ 
-- TBD 