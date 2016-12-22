# BGSE Data Science 2016/17 - Computing Project - Group 7

The main goal of this project is to study trends and correlations of annual national and 
city-level pollutant concentration levels across Europe. The visualization and analysis 
of the dataset should help to form government policies that aim to reduce air pollution 
in Europe over the next 5 years. The pollutant concentration levels are compared to 
reported national pollutant emissions (annual) and population growth (city and national level).

### Structure
The project sources are organized in the following folder structure:
- analysis: Regression code (R) 
- data: Data sources
- db: Database creation and migration scripts (DDL, DML, R)
- doc: Documentation and reporting
- web: Dashboard code (HTML/PHP/JS)  

### Optional TODO list
- [ ] Add missing geo data (roughly 300 cities) with DML script
- [ ] Add mySQL function to replace UNICODE characters in cityNames for geo mapping
- [ ] Check why some cities (eg London) have different city code in population data

### Required packages

The `R` processing relies on the following libraries which get automatically installed if missing:
- openxlsx
- RMySQL
- mgcv (version '1.8.15' or higher)

## Acknowledgments

This project is based on code by: 
- Carlos Isaac Rodriguez Prado
- Hans-Peter Höllwirth
- Veronika Kyuchukova



