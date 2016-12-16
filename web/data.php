<?php?>
<div id="data_view" style="display: none">

  <!-- Country dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="dataCtryButton" onclick="showDataCountries()" class="dropbtn">Country</button>
    <div id="dataCtryDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="dataCountries" onkeyup="filterDataFunction()">
      <?php
        dropdown_countries("selectDataCountry");
      ?>	          
    </div>
  </div> 

  <!-- Pollutant dropdown box -->
  <div class="dropdown" style="float: right;">
    <button id="dataPollutantButton" onclick="showDataPollutants()" class="dropbtn">Pollutant</button>
    <div id="dataPollutantDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="dataPollutantsInput" onkeyup="filterDataPollutants()">     
        <a href='javascript:selectDataPollutant("NO2");'>NO2</a> 
        <a href='javascript:selectDataPollutant("O3");'>O3</a> 
        <a href='javascript:selectDataPollutant("PM10");'>PM10</a> 
        <a href='javascript:selectDataPollutant("PM2.5");'>PM2.5</a>   
        <a href='javascript:selectDataPollutant("BaP");'>BaP</a>       
    </div>
  </div> 
  
  <!-- Descriptive analysis country dropdown functions --> 
  <script>  
    // re-draw graphs 
    function drawDataGraphs(pollutant, countryID) {
        drawConcentrationChart(pollutant, countryID);
        drawExcStationChart(pollutant, countryID);
        drawEmissionChart(pollutant, countryID);
        drawPopulationChart(countryID);    
    }
    
    // show/hide country dropdown list
    function showDataCountries() {
      document.getElementById("dataCtryDropdown").classList.toggle("show");
    }

    // filter function in dropdown list
    function filterDataFunction() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("dataCountries");
      filter = input.value.toUpperCase();
      div = document.getElementById("dataCtryDropdown");
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
    function updateDataHeader(pollutant, countryID) { 
      dataCtryButton = document.getElementById("dataCtryButton");
      dataCtryButton.innerText = getCountryName(countryID);
      dataPollutantButton = document.getElementById("dataPollutantButton");
      dataPollutantButton.innerText = pollutant;
    }
    
    // update charts and header in section upon country selection
    function selectDataCountry(countryID, countryName) {
      dataCountry = countryID;
      updateDataHeader(dataPollutant, countryID);
      showDataCountries();
      drawDataGraphs(dataPollutant, countryID);
    }      
  </script>  
  
  <!-- Descriptive analysis pollutant dropdown box functions --> 
  <script>  
    // show/hide pollutant dropdown list
    function showDataPollutants() {
      document.getElementById("dataPollutantDropdown").classList.toggle("show");
    }

    // filter year function in dropdown list
    function filterDataPollutants() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("dataPollutantsInput");
      filter = input.value.toUpperCase();
      div = document.getElementById("dataPollutantDropdown");
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
    function selectDataPollutant(pollutant) {
      dataPollutant = pollutant;
      updateDataHeader(pollutant, dataCountry);
      showDataPollutants();
      drawDataGraphs(pollutant, dataCountry);
    }    
  </script>     

  <h2 id="dataH2">Data View</h2>
  <div>
    <div id="chart_concentration" style="float: left;"></div>  
    <div id="chart_excStation" style="float: left;"></div>
    <div id="chart_emission" style="float: left;"></div>
    <div id="chart_population" style="float: left;"></div>
  </div>
</div>	
<?php?>