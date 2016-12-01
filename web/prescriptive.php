<?php?>
<div id="pres_analysis" style="display: none">

  <!-- Country dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="paCtryButton" onclick="showCountries('pa')" class="dropbtn">Country</button>
    <div id="paCtryDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="paCountries" onkeyup="filterFunction('pa')">
      <?php
        query_countries('pa');
      ?>	          
    </div>
  </div> 
  
   	  
	<h2 id="paH2">Prescriptive Analysis</h2>
  <div>
    <div id="chart_no2" style="float: left;"></div>
    <div id="chart_o3" style="float: left;"></div>
    <div id="chart_pm10" style="float: left;"></div>   
    <div id="chart_pm2_5" style="float: left;"></div>
  </div>
	
</div>	
<?php?>