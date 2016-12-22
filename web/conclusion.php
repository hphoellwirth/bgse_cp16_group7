<?php?>
<div id="conclusion" style="display: none">    

  <h2>Results</h2>
	<h3>Data</h3>
  <p>The data view illustrates that both concentration level and national pollutant emissions
     were decreasing over the past 10-20 years in most countries (with only very few exceptions). </p> 	
  <p>The map plot suggests that air pollution is a local problem, i.e. differences in observed 
     concentration level between close cities can be large. The point is best illustrated
     with the different NO2 pollution levels of Glasgow and Edinburgh.</p>	
  <p>Nonetheless, the map also supports the idea that the pollution level can be influenced by 
     national policies. Particularly high pollution concentrations are often observed 
     across cities of the same country. Examples are the PM10 concentration in Bulgaria and
     the BaP concentration in Poland.</p>     
 
     
  <h3>Descriptive Analysis</h3>
  <p>No statistical significant correlations between national emissions and city station
     concentration level was observed. The likely explanation for this is that national emission 
     levels are too general. One probably would need city level emission data to find significant relations.</p>
  <p>However, we observed that the size of population in most countries has a significant 
     positive correlation on the concentration level. </p>
  <p>Also, we found a significant relation between the geographical location of cities
     and their pollutant concentration levels: pollution tends to be lower in the north and
     west of Europe. </p>     
  <p>We also conducted some sensitivity analysis on the pollutant concentration level. 
     In particular, we were interested whether the addition of new stations had any
     signifiant impact on the concentration means. The analysis compares the mean of
     all stations with the mean of stations added before 2000 and 2005, respectively.
     The output suggests that the addition of new station indeed reduced the mean concentration
     for most country-pollutant combinations (example: NO2 concentration in Italy), but even if we
     account for this effect, concentration levels were still decreasing overall.</p>
  
  <h3>Predictive Analysis</h3>
  <p>Since no time-related statistical significant correlations with sufficient R-squared could be 
     obtained from the dataset, the pollutant concentration predictions for the years
     2014-2018 rely on time-series analysis.</p>	
  <p>Time-series analysis was conducted both on station-level and national level. 
     Using the station-level predictions also allowed for estimations of the percentage of 
     stations above the limit for future years.</p>    
  <p>On average, national-level predictions look more realistic because they often capture
     the observed downward trends - particularly where data was available for at least 15 years. 
     Station-level predictions suffered from the fact that many stations were only added very
     recently (and sometimes older stations replaced), thus not allowing for a statistical significant 
     trend projection. The error bounds, however, are larger for national-level predictions.</p>
                   
</div>	
<?php?>