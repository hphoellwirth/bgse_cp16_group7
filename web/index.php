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
    <!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script type="text/javascript">
    
    // Load the Visualization API and the piechart package.
    google.charts.load('current', {'packages':['corechart']});
      
    // Set a callback to run when the Google Visualization API is loaded.
    google.charts.setOnLoadCallback(drawChart);
      
    function drawChart() {
      var jsonData = $.ajax({
          url: "functions.php?function=query_and_return_json",
          dataType: "json",
          async: false
          }).responseText;
          
      // Create our data table out of JSON data loaded from server.
      var data = new google.visualization.DataTable(jsonData);
      
      var options = {
          title: 'Company Performance',
          curveType: 'function',
          legend: { position: 'bottom' }
      };

      // Instantiate and draw our chart, passing in some options.
      //var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
      //chart.draw(data, {width: 400, height: 240});
      var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
      chart.draw(data, options);
    }

    </script>    
  </head>
  
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
  
  <!-- Body -->
  <body>
    <div id="header"><h1>European air pollution analysis</h1></div>
    
    <div id="menu">
		<a id="home_link" href="#" class="active" onclick="show_content('home'); return false;">Home</a> &middot;
		<a id="data_link" href="#" onclick="show_content('data'); update_data_charts(); return false;">Data</a> &middot;
		<a id="desc_analysis_link" href="#" onclick="show_content('desc_analysis'); return false;">Descriptive Analysis</a> &middot;
		<a id="pres_analysis_link" href="#" onclick="show_content('pres_analysis'); return false;">Prescriptive Analysis</a> 
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
        <div id="chart_div"></div>
		  </div>	    
        
      <div id="data" style="display: none">
	      <h2>Data</h2>
	    </div>	 
	    
	    <div id="desc_analysis" style="display: none">
	      <h2>Descriptive Analysis</h2>
	      <p>The section analysis the main drivers of observed air pollution concentrations for different pollutants across observed countries in Europe.</p>
	    </div>	
	    
	    <div id="pres_analysis" style="display: none">
	      <h2>Prescriptive Analysis</h2>
	    </div>	       
    </div>
        
    <div id="footer">Project team: Carlos Isaac Rodriguez Prado, Hans-Peter H&ouml;llwirth, Veronika Kyuchukova</div>
  </body>
</html>

<?php
	// Close connection
	mysql_close($link);
?>