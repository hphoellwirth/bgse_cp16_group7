<?php?>
<div id="map" style="display: none">

  <!-- Year dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="mapYearButton" onclick="showMapYears()" class="dropbtn">Year</button>
    <div id="mapYearDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="mapYearsInput" onkeyup="filterMapYear()">     
      <?php
        dropdown_years("selectMapYear");
      ?>        
    </div>
  </div>    

  <!-- Pollutant dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="mapPollutantButton" onclick="showMapPollutants()" class="dropbtn">Pollutant</button>
    <div id="mapPollutantDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="mapPollutantsInput" onkeyup="filterMapPollutants()">     
        <a href='javascript:selectMapPollutant("NO2");'>NO2</a> 
        <a href='javascript:selectMapPollutant("O3");'>O3</a> 
        <a href='javascript:selectMapPollutant("PM10");'>PM10</a> 
        <a href='javascript:selectMapPollutant("PM2.5");'>PM2.5</a>         
    </div>
  </div> 
  
  <!-- Map pollutant dropdown box functions --> 
  <script>  
    // show/hide pollutant dropdown list
    function showMapPollutants() {
      document.getElementById("mapPollutantDropdown").classList.toggle("show");
    }

    // filter year function in dropdown list
    function filterMapPollutants() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("mapPollutantsInput");
      filter = input.value.toUpperCase();
      div = document.getElementById("mapPollutantDropdown");
      a = div.getElementsByTagName("a");
      for (i = 0; i < a.length; i++) {
        if (a[i].innerHTML.toUpperCase().indexOf(filter) > -1) {
          a[i].style.display = "";
        } else {
          a[i].style.display = "none";
        }
      }
    }   
    
    // update header in section upon year selection
    function updateMapHeader(pollutant, year) {
      var header, yearButton, pollutantButton;
      header = document.getElementById("mapH2");
      header.innerText = "City Concentration of Pollutant ".concat(pollutant, " in ", year);  
      mapYearButton = document.getElementById("mapYearButton");
      mapYearButton.innerText = year;
      mapPollutantButton = document.getElementById("mapPollutantButton");
      mapPollutantButton.innerText = pollutant;
    }
    
    // update map and header in section upon year selection
    function selectMapPollutant(pollutant) {
      geoMapPollutant = pollutant;
      updateMapHeader(pollutant, geoMapYear);
      showMapPollutants();
      drawMarkersMap(pollutant, geoMapYear);
    }    
  </script>   
  
  <!-- Map year dropdown box functions --> 
  <script>  
    // show/hide year dropdown list
    function showMapYears() {
      document.getElementById("mapYearDropdown").classList.toggle("show");
    }

    // filter year function in dropdown list
    function filterMapYear() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("mapYearsInput");
      filter = input.value.toUpperCase();
      div = document.getElementById("mapYearDropdown");
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
    function selectMapYear(year) {
      geoMapYear = year;
      updateMapHeader(geoMapPollutant, year);
      showMapYears();
      drawMarkersMap(geoMapPollutant, year);
    }    
  </script>    

	<h2 id="mapH2">City Pollutant Concentration</h2>
	<div id="chart_map"></div>	
</div>
<?php?>