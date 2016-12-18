<?php?>
<div id="desc_analysis" style="display: none">

  <!-- Country dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="daCtryButton" onclick="showDescCountries()" class="dropbtn">Country</button>
    <div id="daCtryDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="daCountries" onkeyup="filterDescFunction()">
      <?php
        dropdown_countries("selectDescCountry");
      ?>	          
    </div>
  </div> 
  
  <!-- Year dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="daYearButton" onclick="showDescYears()" class="dropbtn">Year</button>
    <div id="daYearDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="daYearsInput" onkeyup="filterDescYear()">     
      <?php
        dropdown_years("selectDescYear");
      ?>        
    </div>
  </div>   

  <!-- Pollutant dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="daPollutantButton" onclick="showDescPollutants()" class="dropbtn">Pollutant</button>
    <div id="daPollutantDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="daPollutantsInput" onkeyup="filterDescPollutants()">     
        <a href='javascript:selectDescPollutant("NO2");'>NO2</a> 
        <a href='javascript:selectDescPollutant("O3");'>O3</a> 
        <a href='javascript:selectDescPollutant("PM10");'>PM10</a> 
        <a href='javascript:selectDescPollutant("PM2.5");'>PM2.5</a>   
        <a href='javascript:selectDescPollutant("BaP");'>BaP</a>       
    </div>
  </div> 
  
  <!-- Descriptive analysis country dropdown functions --> 
  <script>  
    // re-draw graphs 
    function drawDescGraphs(pollutant, year, countryID) {
        drawPopulationVsConcentration(pollutant, countryID, year);
        drawNewStationsImpactChart(pollutant, countryID);  
    }
    
    // show/hide country dropdown list
    function showDescCountries() {
      document.getElementById("daCtryDropdown").classList.toggle("show");
    }

    // filter function in dropdown list
    function filterDescFunction() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("daCountries");
      filter = input.value.toUpperCase();
      div = document.getElementById("daCtryDropdown");
      a = div.getElementsByTagName("a");
      for (i = 0; i < a.length; i++) {
        if (a[i].innerHTML.toUpperCase().indexOf(filter) > -1) {
          a[i].style.display = "";
        } else {
          a[i].style.display = "none";
        }
      }
    }   
    
    // update header in section upon pollutant or country selection
    function updateDescHeader(pollutant, year, countryID) {
      daCtryButton = document.getElementById("daCtryButton");
      daCtryButton.innerText = getCountryName(countryID);
      daYearButton = document.getElementById("daYearButton");
      daYearButton.innerText = year;
      daPollutantButton = document.getElementById("daPollutantButton");
      daPollutantButton.innerText = pollutant;
    }
    
    // update charts and header in section upon country selection
    function selectDescCountry(countryID, countryName) {
      descCountry = countryID;
      updateDescHeader(descPollutant, descYear, countryID);
      showDescCountries();
      drawDescGraphs(descPollutant, descYear, countryID);
    }      
  </script>  
  
  <!-- Descriptive analysis year dropdown box functions --> 
  <script>  
    // show/hide year dropdown list
    function showDescYears() {
      document.getElementById("daYearDropdown").classList.toggle("show");
    }

    // filter year function in dropdown list
    function filterDescYear() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("daYearsInput");
      filter = input.value.toUpperCase();
      div = document.getElementById("daYearDropdown");
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
    function selectDescYear(year) {
      descYear = year;
      updateDescHeader(descPollutant, year, descCountry);
      showDescYears();
      drawDescGraphs(descPollutant, year, descCountry);
    }    
  </script>   
  
  <!-- Descriptive analysis pollutant dropdown box functions --> 
  <script>  
    // show/hide pollutant dropdown list
    function showDescPollutants() {
      document.getElementById("daPollutantDropdown").classList.toggle("show");
    }

    // filter year function in dropdown list
    function filterDescPollutants() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("daPollutantsInput");
      filter = input.value.toUpperCase();
      div = document.getElementById("daPollutantDropdown");
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
    function selectDescPollutant(pollutant) {
      descPollutant = pollutant;
      updateDescHeader(pollutant, descYear, descCountry);
      showDescPollutants();
      drawDescGraphs(pollutant, descYear, descCountry);
    }    
  </script>    
  
  <h2>Correlation Analysis</h2>
  <div>   
    <div id="chart_pop_vs_conc" style="float: left;"></div> 
    <div style="width: 550px; height: 300px; float: left;"></div>
    <div style="width: 1200px; height: 5px; float: left;"></div>
  </div>
  <br>
  
  <h2>Sensitivity Analysis</h2>
  <div id="chart_newstations" style="float: left;"></div>

</div>	
<?php?>