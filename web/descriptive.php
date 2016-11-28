<?php?>
<div id="desc_analysis" style="display: none">

  <!-- Country dropdown box -->
  <div class="dropdown" style="float: right;">
    <button onclick="daShowCountries()" class="dropbtn">Country</button>
    <div id="daCtryDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="daCountries" onkeyup="daFilterFunction()">
      <?php
        query_countries();
      ?>	          
    </div>
  </div>	  
  <script>
    /* When the user clicks on the button,
    toggle between hiding and showing the dropdown content */
    function daShowCountries() {
      document.getElementById("daCtryDropdown").classList.toggle("show");
    }

    function daFilterFunction() {
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
  </script>     

  <h2>Descriptive Analysis</h2>
  <p>The section analysis the main drivers of observed air pollution concentrations for different pollutants across observed countries in Europe.</p>
 

  <h3>The findings</h3>
  <div id="chart_div"></div>
  <div id="chart_pie"></div>

</div>	
<?php?>