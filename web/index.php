<?php

	include 'functions.php';
	$GLOBALS['graphid'] = 0;

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
    <script src="charts.js" type="text/javascript"></script>    
  </head>
  
  <!-- Menu selection functions --> 
  <script src="menu.js" type="text/javascript"></script>     
   
  <!-- Body -->
  <!--<body onload="setTimeout(function() {initGraphs();}, 5000);">-->
  <!--<body onload="initGraphs();">-->
  <body>
    <div id="header"><h1>European air pollution analysis</h1></div>
    
    <div id="menu">
		<a id="home_link" href="#" class="active" onclick="show_content('home'); return false;">Home</a> &middot;
		<a id="map_link" href="#" onclick="show_content('map'); return false;">Pollutant Map</a> &middot;
		<a id="data_view_link" href="#" onclick="show_content('data_view'); return false;">Data View</a> &middot;
		<a id="desc_analysis_link" href="#" onclick="show_content('desc_analysis'); return false;">Descriptive Analysis</a> &middot;
		<a id="pres_analysis_link" href="#" onclick="show_content('pres_analysis'); return false;">Prescriptive Analysis</a> &middot;
		<a id="conclusion_link" href="#" onclick="show_content('conclusion'); return false;">Conclusion</a> 
    </div>
    
    <div id="main">
		  <div id="home">
			  <h2>Home</h2>
			  <h3>The goal</h3>
			  <p>The main goal of this project is to study trends and correlations of annual 
			     national and city-level pollutant concentration levels across Europe. The
			     visualization and analysis of the dataset should help to form government policies
			     that aim to reduce air pollution in Europe over the next 5 years. The pollutant concentration
			     levels are compared to reported national pollutant emissions (annual) and population
			     growth (city and national level).</p>						

			  <h3>Motivation</h3>
			  <p>Air pollution causes 467,000 premature deaths a year in Europe (<a href="http://www.bbc.com/news/world-europe-38078488">BBC</a>)
			     and reduces average life expectancy by 7 months.</p>

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
		  </div>	    
        	    
	    <?php include 'map.php' ?>
	    <?php include 'data.php' ?>
	    <?php include 'descriptive.php' ?>
	    <?php include 'prescriptive.php' ?>  
	    <?php include 'conclusion.php' ?>      
    </div>
        
    <div id="footer">Project team: Carlos Isaac Rodriguez Prado, Hans-Peter H&ouml;llwirth, Veronika Kyuchukova</div>
  </body>
</html>

<?php
	// Close connection
	mysql_close($link);
?>