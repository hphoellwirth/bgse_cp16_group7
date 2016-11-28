<?php?>
<div id="data" style="display: none">

  <!-- Country dropdown box -->
  <div class="dropdown" style="float: right;">
    <button onclick="showCountries('data')" class="dropbtn">Country</button>
    <div id="dataCtryDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="dataCountries" onkeyup="filterFunction('data')">
      <?php
        query_countries('data');
      ?>	          
    </div>
  </div>  

	<h2 id="dataH2">Data</h2>
</div>
<?php?>