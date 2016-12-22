    
// Load the visualization API for Google charts
google.charts.load('current', {'packages':['corechart']});
google.charts.load('current', {'packages':['line']});
google.charts.load('current', {'packages':['scatter']});
google.charts.load('current', {'packages': ['geochart']});     
  
// initialize default year/country/pollutant type
var geoMapYear = 2013;
var geoMapPollutant = 'NO2';
var dataCountry = 'ES';
var dataPollutant = 'NO2';
var descYear = 2013;
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
  updateDescHeader(descPollutant, descYear, descCountry);
  drawLongitudeVsConcentration(descPollutant, descYear);
  drawLatitudeVsConcentration(descPollutant, descYear);
  drawPopulationVsConcentration(descPollutant, descCountry, descYear);
  drawNewStationsImpactChart(descPollutant, descCountry); 
  
  // initialize prescriptive analysis graphs
  updatePrescHeader(prescPollutant, prescCountry);        
  drawStationConcForecastChart(prescPollutant, prescCountry);
  drawExcStationForecastChart(prescPollutant, prescCountry);
  drawCountryConcForecastChart(prescPollutant, prescCountry);  
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

// is longitude correlation for given pollutant and year significant?
function isCorrLongitudeSignificant(pollutant, year) {  
  var significant = $.ajax({
      type: "POST",     
      data: {pollutant: pollutant,
             year: year}, 
      url: "functions.php?function=query_corrLongitudeSignificant",
      dataType: "text",
      async: false         
      }).responseText;   
  return significant;
}  

// is latitude correlation for given pollutant and year significant?
function isCorrLatitudeSignificant(pollutant, year) {  
  var significant = $.ajax({
      type: "POST",     
      data: {pollutant: pollutant,
             year: year}, 
      url: "functions.php?function=query_corrLatitudeSignificant",
      dataType: "text",
      async: false         
      }).responseText;   
  return significant;
}

// is population correlation for given pollutant, country, and year significant?
function isCorrPopulationSignificant(pollutant, countryID, year) {  
  var significant = $.ajax({
      type: "POST",     
      data: {pollutant: pollutant,
             countryID: countryID,
             year: year}, 
      url: "functions.php?function=query_corrPopulationSignificant",
      dataType: "text",
      async: false         
      }).responseText;   
  return significant;
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

// draw scatter plot of city longitude vs concentration level
function drawLongitudeVsConcentration(pollutant, year) {
  var jsonData = $.ajax({
      type: "POST",
      data: {pollutant: pollutant,
             year: year},     
      url: "functions.php?function=query_longitude_vs_concentration",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);     

  if (isCorrLongitudeSignificant(pollutant, year) == '0') {     
     var options = {
        title: 'City longitude versus concentration level',
        legend: 'none',
        width: 550,
        height: 300,    
        pointSize: 3,                    
        vAxis: {minValue: 0,
                title: getPollutantUnit(pollutant)},
        hAxis: {viewWindowMode: 'maximized', 
                title: 'longitude'}
    };
  } else {
    var options = {
        title: 'City longitude versus concentration level',
        legend: 'none',
        width: 550,
        height: 300,    
        pointSize: 3,
        trendlines: {
          0: {
            type: 'linear',
            color: 'red',
            lineWidth: 2,
            opacity: 0.5,
            showR2: true
          }},                    
        vAxis: {minValue: 0,
                title: getPollutantUnit(pollutant)},
        hAxis: {viewWindowMode: 'maximized', 
                title: 'longitude'}
    }; 
  }    

  var chart = new google.visualization.ScatterChart(document.getElementById('chart_long_vs_conc'));
  chart.draw(data, options);
} 

// draw scatter plot of city latitude vs concentration level
function drawLatitudeVsConcentration(pollutant, year) {
  var jsonData = $.ajax({
      type: "POST",
      data: {pollutant: pollutant,
             year: year},     
      url: "functions.php?function=query_latitude_vs_concentration",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);     
  
  if (isCorrLatitudeSignificant(pollutant, year) == '0') {   
    var options = {
        title: 'City latitude versus concentration level',
        legend: 'none',
        width: 550,
        height: 300,    
        pointSize: 3,                   
        vAxis: {minValue: 0,
                title: getPollutantUnit(pollutant)},
        hAxis: {viewWindowMode: 'maximized', 
                title: 'latitude'}
    };
  } else {  
    var options = {
        title: 'City latitude versus concentration level',
        legend: 'none',
        width: 550,
        height: 300,    
        pointSize: 3,
        trendlines: {
          0: {
            type: 'linear',
            color: 'red',
            lineWidth: 2,
            opacity: 0.5,
            showR2: true
          }},                    
        vAxis: {minValue: 0,
                title: getPollutantUnit(pollutant)},
        hAxis: {viewWindowMode: 'maximized', 
                title: 'latitude'}
    };   
  }
  
  var chart = new google.visualization.ScatterChart(document.getElementById('chart_lat_vs_conc'));
  chart.draw(data, options);
}

// draw scatter plot of city population vs concentration level
function drawPopulationVsConcentration(pollutant, countryID, year) {
  var jsonData = $.ajax({
      type: "POST",
      data: {pollutant: pollutant,
             countryID: countryID,
             year: year},     
      url: "functions.php?function=query_population_vs_concentration",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);     
  
  if (isCorrPopulationSignificant(pollutant, countryID, year) == '0') {
    var options = {
        title: 'City population versus concentration level',
        legend: 'none',
        width: 550,
        height: 300,  
        pointSize: 5,                       
        vAxis: {minValue: 0,
                title: getPollutantUnit(pollutant)},
        hAxis: {title: 'city population',
                logScale: true}
    };
  } else {    
    var options = {
        title: 'City population versus concentration level',
        legend: 'none',
        width: 550,
        height: 300,
        pointSize: 5,     
        trendlines: {
          0: {
            type: 'linear',
            color: 'red',
            lineWidth: 2,
            opacity: 0.5,
            showR2: true
          }},                    
        vAxis: {minValue: 0,
                title: getPollutantUnit(pollutant)},
        hAxis: {title: 'city population',
                logScale: true}
    };
  }    

  var chart = new google.visualization.ScatterChart(document.getElementById('chart_pop_vs_conc'));
  chart.draw(data, options);
} 

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

// draw forecast of station-level pollutant concentration chart for specific country
function drawStationConcForecastChart(pollutant, countryID) {
  var jsonData = $.ajax({
      type: "POST",
      data: {countryID: countryID,
             pollutant: pollutant},      
      url: "functions.php?function=query_station_forecast",
      dataType: "json",
      async: false         
      }).responseText;
  var data = new google.visualization.DataTable(jsonData);
  
  var options = {
      title: getPollutantTitle(pollutant).concat(" forecast (station level)"),       
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

  var chart = new google.visualization.LineChart(document.getElementById('chart_station_conc_forecast'));
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

// draw forecast of country-level pollutant concentration chart for specific country
function drawCountryConcForecastChart(pollutant, countryID) {
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
      title: getPollutantTitle(pollutant).concat(" forecast (country level)"),       
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

  var chart = new google.visualization.LineChart(document.getElementById('chart_ctry_conc_forecast'));
  chart.draw(data, options);
}       

// initial draw of charts
google.charts.setOnLoadCallback(initGraphs);
