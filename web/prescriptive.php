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
  
  <!-- Pollutant dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="paPollutantButton" onclick="showPrescPollutants()" class="dropbtn">Pollutant</button>
    <div id="paPollutantDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="paPollutantsInput" onkeyup="filterPrescPollutants()">     
        <a href='javascript:selectPrescPollutant("NO2");'>NO2</a> 
        <a href='javascript:selectPrescPollutant("O3");'>O3</a> 
        <a href='javascript:selectPrescPollutant("PM10");'>PM10</a> 
        <a href='javascript:selectPrescPollutant("PM2.5");'>PM2.5</a>   
        <a href='javascript:selectPrescPollutant("BaP");'>BaP</a>       
    </div>
  </div>   

 <!-- Country dropdown box functions --> 
  <script>  
    // re-draw graphs 
    function drawPrescGraphs(pollutant, countryID) { 
        drawStationConcForecastChart(pollutant, countryID);  
        drawExcStationForecastChart(pollutant, countryID);  
        drawCountryConcForecastChart(pollutant, countryID); 
    }
      
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
    function updatePrescHeader(pollutant, countryID) { 
      paCtryButton = document.getElementById("paCtryButton");
      paCtryButton.innerText = getCountryName(countryID);
      paPollutantButton = document.getElementById("paPollutantButton");
      paPollutantButton.innerText = pollutant;          
    }
    
    // update charts and header in section upon country selection
    function selectPrescCountry(countryID, countryName) {
      prescCountry = countryID;
      updatePrescHeader(prescPollutant, countryID);
      showPrescCountries();
      drawPrescGraphs(prescPollutant, countryID);
    }            
  </script> 
  
  <!-- Descriptive analysis pollutant dropdown box functions --> 
  <script>  
    // show/hide pollutant dropdown list
    function showPrescPollutants() {
      document.getElementById("paPollutantDropdown").classList.toggle("show");
    }

    // filter year function in dropdown list
    function filterPrescPollutants() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("paPollutantsInput");
      filter = input.value.toUpperCase();
      div = document.getElementById("paPollutantDropdown");
      a = div.getElementsByTagName("a");
      for (i = 0; i < a.length; i++) {
        if (a[i].innerHTML.toUpperCase().indexOf(filter) > -1) {
          a[i].style.display = "";
        } else {
          a[i].style.display = "none";
        }
      }
    }   
    
    // update map and header in section upon year selection
    function selectPrescPollutant(pollutant) {
      prescPollutant = pollutant;
      updatePrescHeader(pollutant, prescCountry);
      showPrescPollutants();
      drawPrescGraphs(pollutant, prescCountry);
    }    
  </script>     
   	  
	<h2 id="paH2">Prescriptive Analysis</h2>
  <div>
    <div id="chart_station_conc_forecast" style="float: left;"></div>
    <div id="chart_excStation_forecast" style="float: left;"></div>
    <div id="chart_ctry_conc_forecast" style="float: left;"></div>
  </div>
	
</div>	
<?php?>