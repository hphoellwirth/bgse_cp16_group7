# BGSE Data Science 2016/17 - Computing Project - Group 7

Details to follow

### Structure
The project sources are organized in the following folder structure:
- analysis: Regression code (R) 
- data: Data sources
- db: Database creation and migration scripts (DDL, DML, R)
- doc: Documentation and reporting
- web: Dashboard code (HTML/PHP)  

### Implementation
TBD

### TODO list
- [ ] Add missing geo data (roughly 300 cities) with DML script
- [ ] Add mySQL function to replace UNICODE characters in cityNames for geo mapping
- [ ] Check why some cities (eg London) have different city code in population data
- [ ] Correlation analysis emission high-level sectors
- [ ] Analyse impact of added stations on concentration means (did it cause reduced means?)
- [ ] Plot time-series forecasts (already started for NO2)
- [ ] Analyse correlation of city population size and above-national concentration levels

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



