<?php?>
<div id="desc_analysis" style="display: none">

  <!-- Country dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="daCtryButton" onclick="showCountries('da')" class="dropbtn">Country</button>
    <div id="daCtryDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="daCountries" onkeyup="filterFunction('da')">
      <?php
        query_countries('da');
      ?>	          
    </div>
  </div>  

  <h2 id="daH2">Descriptive Analysis</h2>
  <div>
    <div id="chart_no2" style="float: left;"></div>
    <div id="chart_o3" style="float: left;"></div>
    <div id="chart_pm10" style="float: left;"></div>   
    <div id="chart_pm2_5" style="float: left;"></div>
  </div>
  
  <div id="chart_excStation" style="float: left;"></div>
  <div id="chart_emission" style="float: left;"></div>
  <div id="chart_population" style="float: left;"></div>

</div>	
<?php?>