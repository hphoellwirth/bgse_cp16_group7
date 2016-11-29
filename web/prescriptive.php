<?php?>
<div id="pres_analysis" style="display: none">

  <!-- Country dropdown box -->
  <div class="dropdown" style="float: right;">
    <button onclick="showCountries('pa')" class="dropbtn">Country</button>
    <div id="paCtryDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="paCountries" onkeyup="filterFunction('pa')">
      <?php
        query_countries('pa');
      ?>	          
    </div>
  </div> 
  
   	  
	<h2 id="paH2">Prescriptive Analysis</h2>
  <div id="chart_pie">Pie chart</div>	
	
</div>	
<?php?>