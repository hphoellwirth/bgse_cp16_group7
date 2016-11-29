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

  <!-- Year dropdown box functions --> 
  <script>  
    // show/hide year dropdown list
    function showYears() {
      document.getElementById("yearDropdown").classList.toggle("show");
    }

    // filter year function in dropdown list
    function filterYear() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("yearsInput");
      filter = input.value.toUpperCase();
      div = document.getElementById("yearDropdown");
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
    function updateMapHeader(year) {
      var prefix = "City Pollutant Concentration in ";
      var header;
      header = document.getElementById("dataH2");
      header.innerText = prefix.concat(year);    
    }
    
    // update map and header in section upon year selection
    function selectYear(year) {
      updateMapHeader(year);
      showYears();
    }    
  </script>   

	<h2 id="dataH2">City Pollutant Concentration</h2>
	<div id="chart_map"></div>	
</div>
<?php?>