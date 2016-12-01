<?php?>
<div id="pres_analysis" style="display: none">

  <!-- Country dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="paCtryButton" onclick="showPrescCountries()" class="dropbtn">Country</button>
    <div id="paCtryDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="paCountries" onkeyup="filterPrescFunction()">
      <?php
        dropdown_countries("selectPrescCountry");
      ?>	          
    </div>
  </div> 

 <!-- Country dropdown box functions --> 
  <script>  
    // show/hide country dropdown list
    function showPrescCountries() {
      document.getElementById("paCtryDropdown").classList.toggle("show");
    }

    // filter function in dropdown list
    function filterPrescFunction() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("paCountries");
      filter = input.value.toUpperCase();
      div = document.getElementById("paCtryDropdown");
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
    function updatePrescHeader(countryID) {
      var button;
      button = document.getElementById("paCtryButton");
      button.innerText = getCountryName(countryID);             
    }
    
    // update charts and header in section upon country selection
    function selectPrescCountry(countryID, countryName) {
      prescCountry = countryID;
      updatePrescHeader(countryID);
      showPrescCountries();
      
      drawNO2Chart(countryID);
      drawO3Chart(countryID);
      drawPM10Chart(countryID);
      drawPM25Chart(countryID);
    }            
  </script>   
   	  
	<h2 id="paH2">Prescriptive Analysis</h2>
  <div>
    <div id="chart_no2" style="float: left;"></div>
    <div id="chart_o3" style="float: left;"></div>
    <div id="chart_pm10" style="float: left;"></div>   
    <div id="chart_pm2_5" style="float: left;"></div>
  </div>
	
</div>	
<?php?>