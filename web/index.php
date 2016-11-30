<?php

	include 'functions.php';
	$GLOBALS['graphid'] = 0;

	// Load libraries
	document_header();

	// Create connection
	$link = connect_to_db();
?>

<html>
  <!-- Header -->
  <head>
    <title>airpollution</title>    
    <link rel="stylesheet" type="text/css" href="style.css" />  
    
    <!--Google charts-->
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script type="text/javascript" src="//maps.googleapis.com/maps/api/js?key=AIzaSyDeBdHxE2Pw2z1YHYe4A_8IXmBsu8TPAK0" async="" defer="defer"></script>
    <script type="text/javascript">  
  
    // Load the visualization API for Google charts
    google.charts.load('current', {'packages':['corechart']});
    google.charts.load('current', {'packages':['line']});
    google.charts.load('upcoming', {'packages': ['geochart']});
      
    // Set a callback to run when the Google Visualization API is loaded.
    //google.charts.setOnLoadCallback(drawMarkersMap);
    var geoMapYear = 2013;
    var geoMapPollutant = 'NO2';
    
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
      /*
      var data = google.visualization.arrayToDataTable([
        ['Latitude',   'Longitude', 'City', 'Concentration'],
        [48.2000152800,  16.3666389600, 'Wien', 28.633750],
        [51.2203735500, 4.4150170480, 'Antwerpen', 41.123333]
      ]);
      */

      var options = {
        //sizeAxis: { minValue: 0, maxValue: 100 },
        region: '150', // Europe
        width: 1100,
        displayMode: 'markers',
        colorAxis: {colors: ['green', 'red']} // orange to blue
        //colorAxis: {colors: ['#e7711c', '#4374e0']} // orange to blue
      };

      var chart = new google.visualization.GeoChart(document.getElementById('chart_map'));
      chart.draw(data, options);
    };    
    
    /*
    function drawLineChart(countryID) {
      var jsonData = $.ajax({
          type: "POST",
          data: {countryID: countryID},      
          url: "functions.php?function=query_ctry_pollutants",
          dataType: "json",
          async: false         
          }).responseText;
      var data = new google.visualization.DataTable(jsonData);
      
      var options = {
          title: 'Pollutant concentration',
          curveType: 'function',
          legend: { position: 'bottom' }
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
      chart.draw(data, options);
    }
    */
    
    // draw NO2 pollutant chart for specific country
    function drawNO2Chart(countryID) {
      var jsonData = $.ajax({
          type: "POST",
          data: {countryID: countryID},      
          url: "functions.php?function=query_ctry_no2",
          dataType: "json",
          async: false         
          }).responseText;
      var data = new google.visualization.DataTable(jsonData);
      
      var options = {
          title: 'Nitrogen dioxide (NO2) concentration',
          legend: 'none',
          width: 550,
          height: 300,
          colors: ['red', 'blue'],
          crosshair: { trigger: 'both', opacity: 0.5 },
          dataOpaque: 0.5,
          vAxis: {minValue: 0,
                  title: 'mean \u03BCg/m3',
                  gridlines: {count: 6}}          
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_no2'));
      chart.draw(data, options);
    }
    
    // draw O3 pollutant chart for specific country
    function drawO3Chart(countryID) {
      var jsonData = $.ajax({
          type: "POST",
          data: {countryID: countryID},      
          url: "functions.php?function=query_ctry_o3",
          dataType: "json",
          async: false         
          }).responseText;
      var data = new google.visualization.DataTable(jsonData);
      
      var options = {
          title: 'Ozone (O3) concentration',
          legend: 'none',
          width: 550,
          height: 300,          
          colors: ['red', 'purple'],
          crosshair: { trigger: 'both', opacity: 0.5 },
          dataOpaque: 0.5,
          vAxis: {minValue: 0, 
                  title: 'P93.2 \u03BCg/m3',
                  gridlines: {count: 6}}           
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_o3'));
      chart.draw(data, options);
    }        
    
    // draw PM10 pollutant chart for specific country
    function drawPM10Chart(countryID) {
      var jsonData = $.ajax({
          type: "POST",
          data: {countryID: countryID},      
          url: "functions.php?function=query_ctry_pm10",
          dataType: "json",
          async: false         
          }).responseText;
      var data = new google.visualization.DataTable(jsonData);
      
      var options = {
          title: 'Particulate matter < 10 \u03BCm (PM10) concentration',
          legend: 'none',
          width: 550,
          height: 300,          
          colors: ['red', 'orange'],
          crosshair: { trigger: 'both', opacity: 0.5 },
          dataOpaque: 0.5,
          vAxis: {minValue: 0, 
                  title: 'P90.4 \u03BCg/m3',
                  gridlines: {count: 6}}
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_pm10'));
      chart.draw(data, options);
    }   
    
    // draw PM2.5 pollutant chart for specific country
    function drawPM25Chart(countryID) {
      var jsonData = $.ajax({
          type: "POST",
          data: {countryID: countryID},      
          url: "functions.php?function=query_ctry_pm2_5",
          dataType: "json",
          async: false         
          }).responseText;
      var data = new google.visualization.DataTable(jsonData);
      
      var options = {
          title: 'Particulate matter < 2.5 \u03BCm (PM2.5) concentration',
          legend: 'none',
          width: 550,
          height: 300,          
          colors: ['red', 'green'],
          crosshair: { trigger: 'both', opacity: 0.5 },
          dataOpaque: 0.5,
          vAxis: {minValue: 0, 
                  title: 'mean \u03BCg/m3',
                  gridlines: {count: 6}}
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_pm2_5'));
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
          dataOpaque: 0.5
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_population'));
      chart.draw(data, options);
    }     
    
    // draw emission chart for specific country
    function drawEmissionChart(countryID) {
      var jsonData = $.ajax({
          type: "POST",
          data: {countryID: countryID},      
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
          vAxis: {title: 'Gg (1000 tonnes)'},            
          crosshair: { trigger: 'both', opacity: 0.5 },
          dataOpaque: 0.5
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_emission'));
      chart.draw(data, options);
    }         
    
    /*
    function drawPieChart(countryID) {
      var jsonData = $.ajax({
          type: "POST",
          data: {countryID: countryID},            
          url: "functions.php?function=query_and_return_json",
          dataType: "json",         
          async: false         
          }).responseText;  
      var data = new google.visualization.DataTable(jsonData);

      var chart = new google.visualization.PieChart(document.getElementById('chart_pie'));
      chart.draw(data, {width: 400, height: 240});
    }   */  

    </script>    
  </head>
  
  <!-- Menu selection functions --> 
  <script>
    /**
    * Given an element, or an element ID, blank its style's display
    * property (return it to default)
    */
    
    function show(element) {
      if (typeof(element) != "object")	{
	      element = document.getElementById(element);
      }
    
      if (typeof(element) == "object") {
	      element.style.display = '';
      }
    }

    /**
    * Given an element, or an element ID, set its style's display property
    * to 'none'
    */
    function hide(element) {
      if (typeof(element) != "object")	{
	      element = document.getElementById(element);
      }
    
      if (typeof(element) == "object") {
	      element.style.display = 'none';
      }
    }

    function show_content(optionsId) {
	    var ids = new Array('home','map','desc_analysis','pres_analysis');
	    show(optionsId);
	    document.getElementById(optionsId + '_link').className = 'active';

	    for (var i = 0; i < ids.length; i++)
	    {
	      if (ids[i] == optionsId) continue;
	      hide(ids[i]);
	      document.getElementById(ids[i] + '_link').className = '';
	    }
    }
  </script>
  
  <!-- Country dropdown box functions --> 
  <script>  
    // show/hide country dropdown list
    function showCountries(prefix) {
      document.getElementById(prefix.concat("CtryDropdown")).classList.toggle("show");
    }

    // filter function in dropdown list
    function filterFunction(prefix) {
      var input, filter, ul, li, a, i;
      input = document.getElementById(prefix.concat("Countries"));
      filter = input.value.toUpperCase();
      div = document.getElementById(prefix.concat("CtryDropdown"));
      a = div.getElementsByTagName("a");
      for (i = 0; i < a.length; i++) {
        if (a[i].innerHTML.toUpperCase().indexOf(filter) > -1) {
          a[i].style.display = "";
        } else {
          a[i].style.display = "none";
        }
      }
    }   
    
    // update header in section upon country selection
    function updateHeader(prefix, countryName) {
      var header, button;
      //header = document.getElementById(prefix.concat("H2"));
      //header.innerText = countryName; 
      button = document.getElementById(prefix.concat("CtryButton"));
      button.innerText = countryName;             
    }
    
    // update charts and header in section upon country selection
    function selectCountry(prefix, countryID, countryName) {
      updateHeader(prefix, countryName);
      showCountries(prefix);
      
      if (prefix == 'da') {
        drawNO2Chart(countryID);
        drawO3Chart(countryID);
        drawPM10Chart(countryID);
        drawPM25Chart(countryID);
        drawEmissionChart(countryID);
        drawPopulationChart(countryID);
      } else { 
        drawPieChart(countryID);
      }
    }      
  </script> 
  
  <!-- Pollutant dropdown box functions --> 
  <script>  
    // show/hide pollutant dropdown list
    function showPollutants() {
      document.getElementById("pollutantDropdown").classList.toggle("show");
    }

    // filter year function in dropdown list
    function filterPollutants() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("pollutantsInput");
      filter = input.value.toUpperCase();
      div = document.getElementById("pollutantDropdown");
      a = div.getElementsByTagName("a");
      for (i = 0; i < a.length; i++) {
        if (a[i].innerHTML.toUpperCase().indexOf(filter) > -1) {
          a[i].style.display = "";
        } else {
          a[i].style.display = "none";
        }
      }
    }   
    
    // update header in section upon year selection
    function updateMapHeader(pollutant, year) {
      var header, yearButton, pollutantButton;
      header = document.getElementById("mapH2");
      header.innerText = "City Concentration of Pollutant ".concat(pollutant, " in ", year);  
      yearButton = document.getElementById("yearButton");
      yearButton.innerText = year;
      pollutantButton = document.getElementById("pollutantButton");
      pollutantButton.innerText = pollutant;
    }
    
    // update map and header in section upon year selection
    function selectPollutant(pollutant) {
      geoMapPollutant = pollutant;
      updateMapHeader(pollutant, geoMapYear);
      showPollutants();
      drawMarkersMap(pollutant, geoMapYear);
    }    
  </script>   
  
  <!-- Year dropdown box functions --> 
  <script>  
    // show/hide year dropdown list
    function showYears() {
      document.getElementById("yearDropdown").classList.toggle("show");
    }

    // filter year function in dropdown list
    function filterYear() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("yearsInput");
      filter = input.value.toUpperCase();
      div = document.getElementById("yearDropdown");
      a = div.getElementsByTagName("a");
      for (i = 0; i < a.length; i++) {
        if (a[i].innerHTML.toUpperCase().indexOf(filter) > -1) {
          a[i].style.display = "";
        } else {
          a[i].style.display = "none";
        }
      }
    }   
    
    // update map and header in section upon year selection
    function selectYear(year) {
      geoMapYear = year;
      updateMapHeader(geoMapPollutant, year);
      showYears();
      drawMarkersMap(geoMapPollutant, year);
    }    
  </script>     
 
  <!-- Initialize graphs --> 
  <script>  
    function initGraphs() {
      // initialize geo map
      updateMapHeader(geoMapPollutant, geoMapYear);
      drawMarkersMap(geoMapPollutant, geoMapYear);
      
      // initialize concentration line graphs
      updateHeader('da', 'Spain');
      drawNO2Chart('ES');
      drawO3Chart('ES');
      drawPM10Chart('ES');
      drawPM25Chart('ES');   
      drawEmissionChart('ES');
      drawPopulationChart('ES');   
    }   
  </script>   
  
  <!-- Body -->
  <body onload=initGraphs()>
    <div id="header"><h1>European air pollution analysis</h1></div>
    
    <div id="menu">
		<a id="home_link" href="#" class="active" onclick="show_content('home'); return false;">Home</a> &middot;
		<a id="map_link" href="#" onclick="show_content('map'); update_data_charts(); return false;">Pollutant Map</a> &middot;
		<a id="desc_analysis_link" href="#" onclick="show_content('desc_analysis'); return false;">Descriptive Analysis</a> &middot;
		<a id="pres_analysis_link" href="#" onclick="show_content('pres_analysis'); return false;">Prescriptive Analysis</a> 
		<!-- <a id="pres_analysis_link" href="javascript:void(0)" onclick="myFunction()">Prescriptive Analysis</a> -->
    </div>
    
    <div id="main">
		  <div id="home">
			  <h2>Home</h2>
			  <h3>The goal</h3>
			  <p>The main goal of this project is to shed light on the possible measures that an 
			     emission (reduction) government policy could consider in order to reduce the 
			     air pollution most efficiently, and to predict city pollutant concentrations 
			     for future years, assuming no policy changes. For this purpose, 
			     we want to learn which emission sectors impact the measured air pollutants 
			     most in a country (and to what extend) and also try to relate 
			     the measured pollutions to the size of city populations.</p>						

			  <h3>The dataset</h3>
			  <p>The analysis is based on 3 different datasets, provided by the <a href="http://www.eea.europa.eu">European Environment Agency (EEA)</a></p>
        <ol>
          <li>The <a href="http://www.eea.europa.eu/data-and-maps/data/air-pollutant-concentrations-at-station#tab-metadata">first dataset</a> 
              captures annual air pollutant concentrations at station, city, and national level 
              from 36 states (EU28, BIH, ISL, LIE, MKD, MNE, SRB, SUI, TUR). 
              The dataset assesses the population's exposure to 5 types of air pollutants: 
              <ul style="list-style-type:circle">
                <li>Nitrogen dioxide (<b>NO2</b>)</li>
                <li>Ozone (<b>O3</b>)</li>
                <li>Particulate matter < 2.5&mu;m (<b>PM2.5</b>) / < 10&mu;m (<b>PM10</b>)</li> 
                <li>Benzo(a)pyrene (<b>BaP</b>)</li> 
              </ul>
              as measured from roughly 1,000 official monitoring stations in European 
              cities over several years (depending on station) until 2012. Data for 2013 was provided in a separate data file. 
              The stationary dataset consists of roughly 50,000 records.</li>
          <li>The <a href="http://www.eea.europa.eu/data-and-maps/data/national-emissions-reported-to-the-convention-on-long-range-transboundary-air-pollution-lrtap-convention-10#tab-metadata">second dataset</a> 
              captures national annual emissions reported to the convention 
              on long-range transboundary air pollution by 31 states (EU28, ISL, NOR, SUI). 
              The dataset breaks down emissions in terms of pollutants,including NO2, PM2.5, PM10 (but not O3 and BaP), 
              as well as sectors such as transport, residential, agriculture and natural emissions
              for the years 1990 - 2014. The dataset consists of over 3 million records.</li>
          <li>In addition to that, we loaded <a href="http://ec.europa.eu/eurostat/web/cities/data/database">annual population data</a> for the national and city level.</li>
        </ol>
      
			  <!--
        <?php
          // Emission data
          //$query = "SELECT year, emission FROM airpollution.emission WHERE pollutantID = 'PM10' AND sectorID = '1A3ai(i)' AND countryID = 'AT'";
          //$title = "PM10 emission in AT (sector 1A3ai(i))";
          //query_and_print_graph($query,$title,"Gg");
        ?>			
        -->

			  <h3>The findings</h3>
			  <p>TBD</p>
		  </div>	    
        	    
	    <?php include 'map.php' ?>
	    <?php include 'descriptive.php' ?>
	    <?php include 'prescriptive.php' ?>       
    </div>
        
    <div id="footer">Project team: Carlos Isaac Rodriguez Prado, Hans-Peter H&ouml;llwirth, Veronika Kyuchukova</div>
  </body>
</html>

<?php
	// Close connection
	mysql_close($link);
?>