    
// Load the visualization API for Google charts
google.charts.load('current', {'packages':['corechart']});
google.charts.load('current', {'packages':['line']});
google.charts.load('current', {'packages': ['geochart']});     
  
// initialize default year/country/pollutant type
var geoMapYear = 2013;
var geoMapPollutant = 'NO2';
var dataCountry = 'ES';
var dataPollutant = 'NO2';
var descCountry = 'ES';
var descPollutant = 'NO2';
var prescCountry = 'ES';
var prescPollutant = 'NO2';

// draw graphs
function initGraphs() {   
  //console.log(google.visualization);

  // initialize geo map
  updateMapHeader(geoMapPollutant, geoMapYear);
  drawMarkersMap(geoMapPollutant, geoMapYear);

  // initialize data view graphs
  updateDataHeader(dataPollutant, dataCountry);
  drawConcentrationChart(dataPollutant, dataCountry); 
  drawExcStationChart(dataPollutant, dataCountry);
  drawEmissionChart(dataPollutant, dataCountry);
  drawPopulationChart(dataCountry);  

  // initialize descriptive analysis graphs
  updateDescHeader(descPollutant, descCountry);
  drawNewStationsImpactChart(descPollutant, descCountry); 
  
  // initialize prescriptive analysis graphs
  updatePrescHeader(prescPollutant, prescCountry);      
  drawConcentrationForecastChart(prescPollutant, prescCountry);
  drawExcStationForecastChart(prescPollutant, prescCountry);  
}       

// set pollutant concentration chart title
function getPollutantTitle(pollutantID) {
  switch(pollutantID) {
    case 'NO2': text = 'Nitrogen dioxide (NO2) concentration'; break;
    case 'O3': text = 'Ozone (O3) concentration'; break;
    case 'PM10': text = 'Particulate matter < 10 \u03BCm (PM10) concentration'; break;
    case 'PM2.5': text = 'Particulate matter < 2.5 \u03BCm (PM2.5) concentration'; break;
    case 'BaP': text = 'Benzo(a)pyrene concentration'; break;
    default: text = "None";
  }     
  return text;
}

// set pollutant concentration chart y-axis
function getPollutantUnit(pollutantID) {
  switch(pollutantID) {
    case 'NO2': text = 'mean \u03BCg/m3'; break;
    case 'O3': text = 'P93.2 \u03BCg/m3'; break;
    case 'PM10': text = 'P90.4 \u03BCg/m3'; break;
    case 'PM2.5': text = 'mean \u03BCg/m3'; break;
    case 'BaP': text = 'mean ng/m3'; break;
    default: text = "None";
  }     
  return text;
}    

// get country name for button label
function getCountryName(countryID) {
  var countryName = $.ajax({
      type: "POST",     
      data: {countryID: countryID}, 
      url: "functions.php?function=query_countryName",
      dataType: "text",
      async: false         
      }).responseText;    
  return countryName;
}   


////////////////
// Map chart  //
////////////////

// draw geo map with city pollutant concentrations
function drawMarkersMap(pollutant, year) {
  var jsonData = $.ajax({
      type: "POST",     
      data: {pollutant: pollutant,
             year: year}, 
      url: "functions.php?function=query_city_map",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);    

  var options = {
    region: '150', // Europe
    width: 1100,
    displayMode: 'markers',
    colorAxis: {colors: ['green', 'red']} // green to red
  };

  var chart = new google.visualization.GeoChart(document.getElementById('chart_map'));
  chart.draw(data, options);
}; 


//////////////////
// Data charts  //
//////////////////

// draw pollutant concentration chart for specific country
function drawConcentrationChart(pollutant, countryID) {
  var jsonData = $.ajax({
      type: "POST",
      data: {pollutant: pollutant,
             countryID: countryID},      
      url: "functions.php?function=query_concentration",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);
  
  var options = {
      title: getPollutantTitle(pollutant),
      legend: 'none',
      width: 550,
      height: 300,
      crosshair: { trigger: 'both', opacity: 0.5 },
      dataOpaque: 0.5,
      vAxis: {minValue: 0,
              title: getPollutantUnit(pollutant),
              gridlines: {count: 6}},
      hAxis: {slantedText: true}          
  };

  var chart = new google.visualization.LineChart(document.getElementById('chart_concentration'));
  chart.draw(data, options);
}  


// draw percentage of stations exceeding limit chart for specific country
function drawExcStationChart(pollutant, countryID) {
  var jsonData = $.ajax({
      type: "POST",
      data: {pollutant: pollutant,
             countryID: countryID},        
      url: "functions.php?function=query_excStation",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);
  
  var options = {
      title: 'Percentage of stations exceeding limit',
      legend: 'none',
      width: 550,
      height: 300, 
      crosshair: { trigger: 'both', opacity: 0.5 },
      dataOpaque: 0.5,          
      vAxis: {minValue: 0,
              maxValue: 1,
              format:"#%"}, 
      hAxis: {slantedText: true}          
  };

  var chart = new google.visualization.LineChart(document.getElementById('chart_excStation'));
  chart.draw(data, options);
}

// draw emission chart for specific country
function drawEmissionChart(pollutant, countryID) {
  var jsonData = $.ajax({
      type: "POST",
      data: {pollutant: pollutant,
             countryID: countryID},         
      url: "functions.php?function=query_emission",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);
  
  var options = {
      title: 'National and sector emissions',
      legend: 'none',
      width: 550,
      height: 300,
      crosshair: { trigger: 'both', opacity: 0.5 },
      dataOpaque: 0.5,           
      vAxis: {title: 'Gg (1000 tonnes)'},  
      hAxis: {slantedText: true}            
  };

  var chart = new google.visualization.LineChart(document.getElementById('chart_emission'));
  chart.draw(data, options);
} 

// draw population chart for specific country
function drawPopulationChart(countryID) {
  var jsonData = $.ajax({
      type: "POST",
      data: {countryID: countryID},      
      url: "functions.php?function=query_population",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);
  
  var options = {
      title: 'National and large city populations',
      legend: 'none',
      width: 550,
      height: 300, 
      series: {0:{targetAxisIndex:0},
               1:{targetAxisIndex:1},
               2:{targetAxisIndex:1},
               3:{targetAxisIndex:1}
              },                   
      crosshair: { trigger: 'both', opacity: 0.5 },
      dataOpaque: 0.5,
      hAxis: {slantedText: true} 
  };

  var chart = new google.visualization.LineChart(document.getElementById('chart_population'));
  chart.draw(data, options);
} 


/////////////////////////
// Descriptive charts  //
///////////////////////// 

// draw new stations impact chart for specific country
function drawNewStationsImpactChart(pollutant, countryID) {
  var jsonData = $.ajax({
      type: "POST",
      data: {pollutant: pollutant,
             countryID: countryID},     
      url: "functions.php?function=query_ctry_new_station_impact",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);
  
  var options = {
      title: 'Impact of added stations on national concentration averages',
      legend: 'none',
      width: 550,
      height: 300,                   
      crosshair: { trigger: 'both', opacity: 0.5 },
      dataOpaque: 0.5,
      vAxis: {minValue: 0,
              title: getPollutantUnit(pollutant),
              gridlines: {count: 6}},
      hAxis: {slantedText: true}
  };

  var chart = new google.visualization.LineChart(document.getElementById('chart_newstations'));
  chart.draw(data, options);
}             


//////////////////////////
// Prescriptive charts  //
//////////////////////////        

// draw forecast of pollutant concentration chart for specific country
function drawConcentrationForecastChart(pollutant, countryID) {
  var jsonData = $.ajax({
      type: "POST",
      data: {countryID: countryID,
             pollutant: pollutant},      
      url: "functions.php?function=query_ctry_forecast",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);
  
  var options = {
      title: getPollutantTitle(pollutant).concat(" forecast"),       
      legend: 'none',
      width: 550,
      height: 300,
      colors: ['red', 'green', 'green', 'blue'],
      crosshair: { trigger: 'both', opacity: 0.5 },
      dataOpaque: 0.5,
      vAxis: {minValue: 0,
              title: getPollutantUnit(pollutant),
              gridlines: {count: 6}},
      hAxis: {slantedText: true}                    
  };

  var chart = new google.visualization.LineChart(document.getElementById('chart_concentration_forecast'));
  chart.draw(data, options);
}

// draw forecast of percentage of stations exceeding limit chart for specific country
function drawExcStationForecastChart(pollutant, countryID) {
  var jsonData = $.ajax({
      type: "POST",
      data: {pollutant: pollutant,
             countryID: countryID},        
      url: "functions.php?function=query_excStation_forecast",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);
  
  var options = {
      title: 'Percentage of stations exceeding limit forecast',
      legend: 'none',
      width: 550,
      height: 300, 
      colors: ['green', 'green', 'blue'],
      crosshair: { trigger: 'both', opacity: 0.5 },
      dataOpaque: 0.5,          
      vAxis: {minValue: 0,
              maxValue: 1,
              format:"#%"},  
      hAxis: {slantedText: true}          
  };

  var chart = new google.visualization.LineChart(document.getElementById('chart_excStation_forecast'));
  chart.draw(data, options);
}           

// initial draw of charts
google.charts.setOnLoadCallback(initGraphs);
