<?php?>
<div id="data" style="display: none">

  <!-- Year dropdown box -->
  <div class="dropdown" style="float: right;">
    <button onclick="showYears()" class="dropbtn">Year</button>
    <div id="yearDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="yearsInput" onkeyup="filterYear()">     
      <?php
        query_years();
      ?>        
    </div>
  </div>    

  <!-- Pollutant dropdown box -->
  <div class="dropdown" style="float: right;">
    <button onclick="showPollutants()" class="dropbtn">Pollutant</button>
    <div id="pollutantDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="pollutantsInput" onkeyup="filterPollutants()">     
        <a href='javascript:selectPollutant("NO2");'>NO2</a> 
        <a href='javascript:selectPollutant("O3");'>O3</a> 
        <a href='javascript:selectPollutant("PM10");'>PM10</a> 
        <a href='javascript:selectPollutant("PM2.5");'>PM2.5</a>         
    </div>
  </div> 

	<h2 id="dataH2">City Pollutant Concentration</h2>
	<div id="chart_map"></div>	
</div>
<?php?>