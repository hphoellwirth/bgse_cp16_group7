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
    <script type="text/javascript">  
    
    // Load the Visualization API and the piechart package.
    google.charts.load('current', {'packages':['corechart']});
      
    // Set a callback to run when the Google Visualization API is loaded.
    //google.charts.setOnLoadCallback(drawLineChart);
    //google.charts.setOnLoadCallback(drawPieChart);
      
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
    
    // NO2 pollutant chart for specific country
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
          colors: ['red', 'blue'],
          crosshair: { trigger: 'both' },
          vAxis: {minValue: 0,
                  title: 'mean \u03BCg/m3',
                  gridlines: {count: 6}}          
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_no2'));
      chart.draw(data, options);
    }
    
    // O3 pollutant chart for specific country
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
          colors: ['red', 'purple'],
          vAxis: {minValue: 0, 
                  title: 'P93.2 \u03BCg/m3',
                  gridlines: {count: 6}}           
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_o3'));
      chart.draw(data, options);
    }        
    
    // PM10 pollutant chart for specific country
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
          colors: ['red', 'orange'],
          vAxis: {minValue: 0, 
                  title: 'P90.4 \u03BCg/m3',
                  gridlines: {count: 6}}
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_pm10'));
      chart.draw(data, options);
    }   
    
    // PM2.5 pollutant chart for specific country
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
          colors: ['red', 'green'],
          vAxis: {minValue: 0, 
                  title: 'mean \u03BCg/m3',
                  gridlines: {count: 6}}
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_pm2_5'));
      chart.draw(data, options);
    }      
    
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
    }    

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
	    var ids = new Array('home','data','desc_analysis','pres_analysis');
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
      var header;
      header = document.getElementById(prefix.concat("H2"));
      header.innerText = countryName;    
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
      } else { 
        drawPieChart(countryID);
      }
    }      
  </script>   
  
  <!-- Body -->
  <body>
    <div id="header"><h1>European air pollution analysis</h1></div>
    
    <div id="menu">
		<a id="home_link" href="#" class="active" onclick="show_content('home'); return false;">Home</a> &middot;
		<a id="data_link" href="#" onclick="show_content('data'); update_data_charts(); return false;">Data</a> &middot;
		<a id="desc_analysis_link" href="#" onclick="show_content('desc_analysis'); return false;">Descriptive Analysis</a> &middot;
		<a id="pres_analysis_link" href="#" onclick="show_content('pres_analysis'); return false;">Prescriptive Analysis</a> 
		<!-- <a id="pres_analysis_link" href="javascript:void(0)" onclick="myFunction()">Prescriptive Analysis</a> -->
    </div>
    
    <div id="main">
		  <div id="home">
			  <h2>Home</h2>
			  <h3>The goal</h3>
			  <p>The main goal of this project is to shed light on the possible measures that an emission (reduction) government policy could consider in order to reduce the air pollution most efficiently, and to predict city pollutant concentrations for future years, assuming no policy changes. For this purpose, we want to learn which emission sectors impact the measured air pollutants most in a country (and to what extend) and also try to relate the measured pollutions to the size of city populations.</p>						


			  <h3>The dataset</h3>
        <?php
          // Emission data
          $query = "SELECT year, emission FROM airpollution.emission WHERE pollutantID = 'PM10' AND sectorID = '1A3ai(i)' AND countryID = 'AT'";
          $title = "PM10 emission in AT (sector 1A3ai(i))";
          query_and_print_graph($query,$title,"Gg");
        ?>			
			  <p>TBD</p>

			  <h3>The findings</h3>
			  <p>TBD</p>
		  </div>	    
        	    
	    <?php include 'data.php' ?>
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