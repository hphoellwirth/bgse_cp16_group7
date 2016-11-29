<?php

// list of approved AJAX function calls
$approved_functions = array('query_and_return_json', 
                            'query_ctry_pollutants',
                            'query_city_map',
                            'query_ctry_no2',
                            'query_ctry_o3',
                            'query_ctry_pm10',
                            'query_ctry_pm2_5');

$func = (isset($_GET['function']) ? $_GET['function'] : null);

// check the $_GET['function'] and see if it matches an approved function
if(in_array($func, $approved_functions)) {
    // call the approved function
    $func();
}

// connect to database
function connect_to_db() {    
    $host = "localhost";
    $dbuser = "gseuser";
    $dbpass = "gsepass";
    $dbname = "airpollution";

    $link = mysql_connect($host,$dbuser,$dbpass);

    if (!$link) {
        die('Could not connect: ' . mysql_error());
    }   
    return $link;  
}

function document_header() {
    $str = <<<MY_MARKER
<link rel='stylesheet' href='files/nv.d3.css' type='text/css'>
<script src='files/d3.v2.js' type='text/javascript' ></script>
<script src='files/nv.d3.js' type='text/javascript' ></script>
<script>
    var mycharts = [];
    function update_data_charts() {
        for (i = 0; i < mycharts.length; i++) {
            mycharts[i]();
        }
    }
</script>
MY_MARKER;
    echo $str;
}

function query_and_print_table($query,$title) {
    // Perform Query
    $result = mysql_query($query);

    // Check result
    // This shows the actual query sent to MySQL, and the error. Useful for debugging.
    if (!$result) {
        $message  = 'Invalid query: ' . mysql_error() . "\n";
        $message .= 'Whole query: ' . $query;
        die($message);
    }

    // Use result
    // Attempting to print $result won't allow access to information in the resource
    // One of the mysql result functions must be used
    // See also mysql_result(), mysql_fetch_array(), mysql_fetch_row(), etc.
    echo "<h2>" . $title . "</h2>";
    echo "<table align='center'>";
    echo "<thead><tr></tr>";
    $row = mysql_fetch_assoc($result);
    foreach ($row as $col => $value) {                
        echo "<th>" . $col . "</th>";
    }
    echo "</tr></thead>";

    // Write rows
    mysql_data_seek($result, 0);
    while ($row = mysql_fetch_assoc($result)) {
        echo "<tr>";
        foreach ($row as $e) {                
            echo "<td>" . $e . "</td>";
        }
        echo "</tr>";
    }
    echo "</table>";

    // Free the resources associated with the result set
    // This is done automatically at the end of the script
    mysql_free_result($result);
}


function query_and_print_graph($query,$title,$ylabel) {
    $id = "graph" . $GLOBALS['graphid'];
    $GLOBALS['graphid'] = $GLOBALS['graphid'] + 1;
    
    echo "<h2>" . $title . "</h2>";
    echo PHP_EOL,'<div id="'. $id . '"><svg style="height:300px"></svg></div>',PHP_EOL;

    // Perform Query
    $result = mysql_query($query);

    // Check result
    // This shows the actual query sent to MySQL, and the error. Useful for debugging.
    if (!$result) {
        $message  = 'Invalid query: ' . mysql_error() . "\n";
        $message .= 'Whole query: ' . $query;
        die($message);
    }

    $str = "<script type='text/javascript'>
        function " . $id . "Chart() {";
    $str = $str . <<<MY_MARKER
    nv.addGraph(function() {
        var chart = nv.models.discreteBarChart()
          .x(function(d) { return d.label })    //Specify the data accessors.
          .y(function(d) { return d.value })
          .staggerLabels(true)    //Too many bars and not enough room? Try staggering labels.
          .tooltips(false)        //Show tooltips
          .showValues(true)       //...instead, show the bar value right on top of each bar.
          .transitionDuration(350);
MY_MARKER;
    $str = $str . PHP_EOL . 'chart.yAxis.axisLabel("' . $ylabel . '").axisLabelDistance(30)';
    $str = $str . PHP_EOL . "d3.select('#" . $id . " svg')
          .datum(" . $id . "Data())
          .call(chart);";
    $str = $str . <<<MY_MARKER
      nv.utils.windowResize(chart.update);

      return chart;
    });
}    
MY_MARKER;
    $str = $str . PHP_EOL . $id . "Chart();" . PHP_EOL;
    $str = $str . PHP_EOL . "mycharts.push(". $id . "Chart)" . PHP_EOL;
    $str = $str . PHP_EOL . "function " . $id . "Data() {
 return  [ 
    {
      key:"; 
    $str = $str . '"' . $title . '", values: [';

    while ($row = mysql_fetch_array($result)) {
        $str = $str . '{ "label":"' . $row[0] . '","value":' . $row[1] . '},' . PHP_EOL;
    }    
    $str = $str . '] } ] }</script>';
    echo $str;

}

function query_and_print_series($query,$title,$label) {
    $id = "graph" . $GLOBALS['graphid'];
    $GLOBALS['graphid'] = $GLOBALS['graphid'] + 1;
    
    echo "<h2>" . $title . "</h2>";
    echo PHP_EOL,'<div align="center" id="'. $id . '"><svg style="height:500px; width:800px"></svg></div>',PHP_EOL;

    // Perform Query
    $result = mysql_query($query);

    // Check result
    // This shows the actual query sent to MySQL, and the error. Useful for debugging.
    if (!$result) {
        $message  = 'Invalid query: ' . mysql_error() . "\n";
        $message .= 'Whole query: ' . $query;
        die($message);
    }

    $str = "<script type='text/javascript'>
        function " . $id . "Chart() {";
    $str = $str . <<<MY_MARKER
    nv.addGraph(function() {
    var chart = nv.models.lineChart()
                .margin({left: 100})  //Adjust chart margins to give the x-axis some breathing room.
                .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                .transitionDuration(350)  //how fast do you want the lines to transition?
                .showLegend(true)       //Show the legend, allowing users to turn on/off line series.
                .showYAxis(true)        //Show the y-axis
                .showXAxis(true)        //Show the x-axis
    ;

    chart.xAxis     //Chart x-axis settings
      .axisLabel('X')
      .tickFormat(d3.format(',r'));

    chart.yAxis     //Chart y-axis settings
      .axisLabel('Y')
      .tickFormat(d3.format('.02f'));

MY_MARKER;

    $str = $str . PHP_EOL . 'chart.yAxis.axisLabel("x").axisLabelDistance(30)';
    $str = $str . PHP_EOL . "d3.select('#" . $id . " svg')
          .datum(" . $id . "Data())
          .call(chart);";
    $str = $str . <<<MY_MARKER
      nv.utils.windowResize(chart.update);

      return chart;
    });
}    
MY_MARKER;

    $str = $str . PHP_EOL . $id . "Chart();" . PHP_EOL;
    $str = $str . PHP_EOL . "mycharts.push(". $id . "Chart)" . PHP_EOL;
    $str = $str . PHP_EOL . "function " . $id . "Data() { 
    var fx = [];";
  
    while ($row = mysql_fetch_array($result)) {
        $str = $str . "fx.push({x:" . $row[0] . ", y:" . $row[1] ."}); " . PHP_EOL;
    }    

    $str = $str . "
    //Line chart data should be sent as an array of series objects.
    return [
    {
      values: fx,
      key: '" . $label . " ',
      color: '#7777ff',
      area: true      //area - set to true if you want this line to turn into a filled area chart.
    }
  ];
}</script>";

    echo $str;

}

// Query all countries for dropdown menu
function query_countries($site) {

    //open connection to database
    connect_to_db(); 

    // perform query
    $query = "SELECT countryID, countryName FROM airpollution.country ORDER BY countryName";
    $result = mysql_query($query);

    // create list of countries
    while ($row = mysql_fetch_array($result)) {
      echo "<a href='javascript:selectCountry(\""
           . $site
           . "\", \"" 
           . $row['countryID'] 
           . "\", \"" 
           . $row['countryName']            
           . "\");'>" 
           . $row['countryName'] 
           . "</a>"; 
    }
}

// Query years for dropdown menu
function query_years() {

    // create list of years
    for ($year = 2013; $year >= 1985; $year--) {
      echo "<a href='javascript:selectYear(\"" 
           . $year 
           . "\");'>" 
           . $year 
           . "</a>"; 
    }
}

// geo map of cities and their concentrations
function query_city_map() {

    if (isset($_POST["pollutant"]) and isset($_POST["year"])) {
      $pollutant = $_POST["pollutant"]; 
      $year = $_POST["year"];
                
      //open connection to database
      connect_to_db(); 
  
      // perform query
      $query = "SELECT latitude, longitude, cityName, concentration FROM airpollution.cityGeoMap WHERE year = " . $year . " AND pollutantID = '" . $pollutant . "'";
      $result = mysql_query($query);

      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'Latitude', 'type' => 'number'),
        array('label' => 'Longitude', 'type' => 'number'),
        array('label' => 'City', 'type' => 'string'),
        array('label' => 'PM10', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (double) $row['latitude']);
        $temp[] = array('v' => (double) $row['longitude']);      
        $temp[] = array('v' => (string) $row['cityName']); 
        $temp[] = array('v' => (double) $row['concentration']);
        $rows[] = array('c' => $temp);    
      }
  
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }

}

// graph of NO2 pollutation for given country
function query_ctry_no2() {

    if (isset($_POST["countryID"])) {
      $countryID = $_POST["countryID"]; 
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, cNO2, lNO2 FROM airpollution.countryConcentrations WHERE countryID = '" . $countryID . "'";
      $result = mysql_query($query);

      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'limit', 'type' => 'number'),
        array('label' => 'NO2', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['lNO2']);
        $temp[] = array('v' => (double) $row['cNO2']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

// graph of O3 pollutation for given country
function query_ctry_o3() {

    if (isset($_POST["countryID"])) {
      $countryID = $_POST["countryID"]; 
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, cO3, lO3 FROM airpollution.countryConcentrations WHERE countryID = '" . $countryID . "'";
      $result = mysql_query($query);

      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'limit', 'type' => 'number'),
        array('label' => 'O3', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['lO3']);
        $temp[] = array('v' => (double) $row['cO3']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

// graph of PM10 pollutation for given country
function query_ctry_pm10() {

    if (isset($_POST["countryID"])) {
      $countryID = $_POST["countryID"]; 
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, cPM10, lPM10 FROM airpollution.countryConcentrations WHERE countryID = '" . $countryID . "'";
      $result = mysql_query($query);

      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'limit', 'type' => 'number'),
        array('label' => 'PM10', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['lPM10']);
        $temp[] = array('v' => (double) $row['cPM10']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

// graph of PM2.5 pollutation for given country
function query_ctry_pm2_5() {

    if (isset($_POST["countryID"])) {
      $countryID = $_POST["countryID"]; 
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, cPM2_5, lPM2_5 FROM airpollution.countryConcentrations WHERE countryID = '" . $countryID . "'";
      $result = mysql_query($query);

      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'limit', 'type' => 'number'),
        array('label' => 'PM2.5', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['lPM2_5']);
        $temp[] = array('v' => (double) $row['cPM2_5']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

function query_ctry_pollutants() {

    if (isset($_POST["countryID"])) {
      $countryID = $_POST["countryID"]; 
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, cPM10, cPM2_5, cNO2, cO3 FROM airpollution.countryConcentrations WHERE countryID = '" . $countryID . "'";
      $result = mysql_query($query);

      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'PM10', 'type' => 'number'),
        array('label' => 'PM2.5', 'type' => 'number'),
        array('label' => 'NO2', 'type' => 'number'),
        array('label' => 'O3', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['cPM10']);
        $temp[] = array('v' => (double) $row['cPM2_5']); 
        $temp[] = array('v' => (double) $row['cNO2']); 
        $temp[] = array('v' => (double) $row['cO3']);  
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

function query_and_return_json() {

    if (isset($_POST["countryID"])) {
      $countryID = $_POST["countryID"]; 
         
      //open connection to database
      connect_to_db(); 
      //$url = $_SERVER['REQUEST_URI'];
    
      // perform Query
      $query = "SELECT year, emission FROM airpollution.emission WHERE pollutantID = 'PM10' AND sectorID = '1A3ai(i)' AND countryID = '" . $countryID . "'";
      $result = mysql_query($query);

      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'emission', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
    
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['emission']); 
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}





?>
