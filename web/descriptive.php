<?php?>
<div id="desc_analysis" style="display: none">

  <!-- Country dropdown box -->
  <div class="dropdown" style="float: right;">
    <button onclick="showCountries('da')" class="dropbtn">Country</button>
    <div id="daCtryDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="daCountries" onkeyup="filterFunction('da')">
      <?php
        query_countries('da');
      ?>	          
    </div>
  </div>  

  <h2 id="daH2">Descriptive Analysis</h2>
  <p>The section analysis the main drivers of observed air pollution concentrations for different pollutants across observed countries in Europe.</p>
  <div id="chart_pie">Pie chart</div>	


</div>	
<?php?>