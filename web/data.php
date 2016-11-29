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

	<h2 id="dataH2">City Pollutant Concentration</h2>
	<div id="chart_map"></div>	
</div>
<?php?>