# -------------------------------------------
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
# -------------------------------------------

/*********************/
/* Insert pollutants */
/*********************/
use airpollution;

insert into pollutant (pollutantID, description, statistic, unitConc, unitEmission, limitDesc, limitConc) values
("NO2", "Nitrogen dioxide (air)", "mean", "µg/m3", "Gg (1000 tonnes)", "", 40),
("O3", "Ozone (air)", "P93.2", "µg/m3", "Gg (1000 tonnes)", "", 120),
("PM10", "Particulate matter < 10 µm (aerosol)", "P90.4", "µg/m3", "Gg (1000 tonnes)", "", 50),
("PM2.5", "Particulate matter < 2.5 µm (aerosol)", "mean", "µg/m3", "Gg (1000 tonnes)", "", 25),
("BaP", "Benzo(a)pyrene (air+aerosol)", "mean", "ng/m3", "Gg (1000 tonnes)", "", 1);

