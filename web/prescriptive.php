<?php?>
<div id="pres_analysis" style="display: none">

  <!-- Country dropdown box -->
  <div class="dropdown" style="float: right;">
    <button onclick="paShowCountries()" class="dropbtn">Country</button>
    <div id="paCtryDropdown" class="dropdown-content">
      <input type="text" placeholder="Search.." id="paCountries" onkeyup="paFilterFunction()">
      <?php
        query_countries();
      ?>	          
    </div>
  </div>  
  <script>
    function paShowCountries() {
      document.getElementById("paCtryDropdown").classList.toggle("show");
    }

    function paFilterFunction() {
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
  </script> 	  
  
	<h2>Prescriptive Analysis</h2>
	
	
	
	
	
	
	

	
</div>	
<?php?>