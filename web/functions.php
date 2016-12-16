<?php

// list of approved AJAX function calls
$approved_functions = array('query_city_map',
                            'query_population',
                            'query_emission',
                            'query_excStation',
                            'query_concentration',
                            'query_countryName',
                            'query_ctry_new_station_impact',
                            'query_station_forecast',
                            'query_excStation_forecast',
                            'query_ctry_forecast');

$func = (isset($_GET['function']) ? $_GET['function'] : null);
if(in_array($func, $approved_functions)) {
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


///////////////////////
// Dropdown buttons  //
///////////////////////

// Query all countries for dropdown menu
function dropdown_countries($selectFunction) {

    //open connection to database
    connect_to_db(); 

    // perform query
    $query = "SELECT countryID, countryName FROM airpollution.country ORDER BY countryName";
    $result = mysql_query($query);

    // create list of countries
    while ($row = mysql_fetch_array($result)) {
      echo "<a href='javascript:"
           . $selectFunction
           . "(\""
           . $row['countryID'] 
           . "\", \"" 
           . $row['countryName']            
           . "\");'>" 
           . $row['countryName'] 
           . "</a>"; 
    }
}

// Query years for dropdown menu
function dropdown_years($selectFunction) {

    // create list of years
    for ($year = 2013; $year >= 1985; $year--) {
      echo "<a href='javascript:"
           . $selectFunction
           . "(\"" 
           . $year 
           . "\");'>" 
           . $year 
           . "</a>"; 
    }
}

function query_countryName() {

    if (isset($_POST["countryID"])) {
      $countryID = $_POST["countryID"]; 
      
      //open connection to database
      connect_to_db();

      // perform query
      $query = "SELECT countryName FROM airpollution.country WHERE countryID = '" . $countryID . "'";
      $result = mysql_query($query);
    
      $row = mysql_fetch_array($result);
      echo $row['countryName'];
    }
}

function query_cityName($countryID, $rank) {

    //open connection to database
    connect_to_db();

    // perform query
    $query = "SELECT CONVERT(cityName USING ascii) as cityName FROM airpollution.largestCities l, airpollution.city c WHERE l.cityID = c.cityID AND l.countryID = '" . $countryID . "' AND rank = " . $rank;
    $result = mysql_query($query);
    
    $row = mysql_fetch_array($result);
    return $row['cityName'];
    
}


///////////////
// Map view  //
///////////////

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
        array('label' => $pollutant, 'type' => 'number')
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


////////////////
// Data view  //
////////////////

// graph showing annual concentrations for given country
function query_concentration() {

    if (isset($_POST["pollutant"]) and isset($_POST["countryID"])) {
      $pollutant = $_POST["pollutant"]; 
      $countryID = $_POST["countryID"]; 
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, cLimit, concentration, concCityR1, concCityR2, concCityR3 FROM airpollution.concentrationView WHERE countryID = '" . $countryID . "' AND pollutantID = '" . $pollutant . "' ORDER BY year";
      $result = mysql_query($query);
      
      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => query_cityName($countryID, 3), 'type' => 'number'),
        array('label' => query_cityName($countryID, 2), 'type' => 'number'),
        array('label' => query_cityName($countryID, 1), 'type' => 'number'),
        array('label' => 'limit', 'type' => 'number'),
        array('label' => 'national', 'type' => 'number')                
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['concCityR3']);
        $temp[] = array('v' => (double) $row['concCityR2']);
        $temp[] = array('v' => (double) $row['concCityR1']);
        $temp[] = array('v' => (double) $row['cLimit']);        
        $temp[] = array('v' => (double) $row['concentration']);        
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

// graph showing percentage of stations exceeding limit for given country
function query_excStation() {

    if (isset($_POST["pollutant"]) and isset($_POST["countryID"])) {
      $pollutant = $_POST["pollutant"]; 
      $countryID = $_POST["countryID"];  
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, pctExcStations, pctExcCityR1, pctExcCityR2, pctExcCityR3 FROM airpollution.excStationView WHERE countryID = '" . $countryID . "' AND pollutantID = '" . $pollutant . "' ORDER BY year";
      $result = mysql_query($query);
      
      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'national', 'type' => 'number'),
        array('label' => query_cityName($countryID, 1), 'type' => 'number'),
        array('label' => query_cityName($countryID, 2), 'type' => 'number'),
        array('label' => query_cityName($countryID, 3), 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['pctExcStations']);
        $temp[] = array('v' => (double) $row['pctExcCityR1']);
        $temp[] = array('v' => (double) $row['pctExcCityR2']);
        $temp[] = array('v' => (double) $row['pctExcCityR3']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

// graph of emissions for given country
function query_emission() {

    if (isset($_POST["pollutant"]) and isset($_POST["countryID"])) {
      $pollutant = $_POST["pollutant"]; 
      $countryID = $_POST["countryID"]; 
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, emission, emission1A1, emission1A2, emission1A3, emission1Ax, emission1B, emission2, emission3, emission5 FROM airpollution.emissionView WHERE countryID = '" . $countryID . "' AND pollutantID = '" . $pollutant . "' ORDER BY year";
      $result = mysql_query($query);
      
      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'total', 'type' => 'number'),
        array('label' => 'energy production', 'type' => 'number'),
        array('label' => 'commercial/residential', 'type' => 'number'),
        array('label' => 'transport', 'type' => 'number'),
        array('label' => 'combustion', 'type' => 'number'),
        array('label' => 'fugitive emission', 'type' => 'number'),
        array('label' => 'production industry', 'type' => 'number'),
        array('label' => 'agriculture', 'type' => 'number'),
        array('label' => 'waste', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['emission']);
        $temp[] = array('v' => (double) $row['emission1A1']);
        $temp[] = array('v' => (double) $row['emission1A2']);
        $temp[] = array('v' => (double) $row['emission1A3']);
        $temp[] = array('v' => (double) $row['emission1Ax']);
        $temp[] = array('v' => (double) $row['emission1B']);
        $temp[] = array('v' => (double) $row['emission2']);
        $temp[] = array('v' => (double) $row['emission3']);
        $temp[] = array('v' => (double) $row['emission5']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

// graph of population for given country
function query_population() {

    if (isset($_POST["countryID"])) {
      $countryID = $_POST["countryID"]; 
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, population, popCityR1, popCityR2, popCityR3 FROM airpollution.populationView WHERE countryID = '" . $countryID . "' ORDER BY year";
      $result = mysql_query($query);
      
      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'national', 'type' => 'number'),
        array('label' => query_cityName($countryID, 1), 'type' => 'number'),
        array('label' => query_cityName($countryID, 2), 'type' => 'number'),
        array('label' => query_cityName($countryID, 3), 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['population']);
        $temp[] = array('v' => (double) $row['popCityR1']);
        $temp[] = array('v' => (double) $row['popCityR2']);
        $temp[] = array('v' => (double) $row['popCityR3']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

///////////////////////
// Descriptive view  //
///////////////////////

function query_ctry_new_station_impact() {

    if (isset($_POST["pollutant"]) and isset($_POST["countryID"])) {
      $pollutant = $_POST["pollutant"]; 
      $countryID = $_POST["countryID"];
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, conc2000Stations, conc2005Stations, concAll, cLimit FROM airpollution.addedStationImpactView WHERE pollutantID = '" . $pollutant . "' AND countryID = '" . $countryID . "'";
      $result = mysql_query($query);

      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'limit', 'type' => 'number'),
        array('label' => 'stations added before 2000', 'type' => 'number'),
        array('label' => 'stations added before 2005', 'type' => 'number'),
        array('label' => 'all stations', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['cLimit']);
        $temp[] = array('v' => (double) $row['conc2000Stations']);
        $temp[] = array('v' => (double) $row['conc2005Stations']);
        $temp[] = array('v' => (double) $row['concAll']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

//////////////////////
// Predictive view  //
//////////////////////

// graph of station-level pollutation forecast for given country
function query_station_forecast() {

    if (isset($_POST["pollutant"]) and isset($_POST["countryID"])) {
      $pollutant = $_POST["pollutant"]; 
      $countryID = $_POST["countryID"];
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, concentration, low95, high95, cLimit FROM airpollution.concentrationStationForecastView WHERE pollutantID = '" . $pollutant . "' AND countryID = '" . $countryID . "'";
      $result = mysql_query($query);

      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'limit', 'type' => 'number'),
        array('label' => 'lower bound (95%)', 'type' => 'number'),
        array('label' => 'upper bound (95%)', 'type' => 'number'),
        array('label' => 'concentration', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['cLimit']);
        $temp[] = array('v' => (double) $row['low95']);
        $temp[] = array('v' => (double) $row['high95']);
        $temp[] = array('v' => (double) $row['concentration']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
} 

// graph showing forecast of percentage of stations exceeding limit for given country
function query_excStation_forecast() {

    if (isset($_POST["pollutant"]) and isset($_POST["countryID"])) {
      $pollutant = $_POST["pollutant"]; 
      $countryID = $_POST["countryID"];  
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, pctExcStations, pctExcStationsLow95, pctExcStationsHigh95 FROM airpollution.excStationForecastView WHERE countryID = '" . $countryID . "' AND pollutantID = '" . $pollutant . "' ORDER BY year";
      $result = mysql_query($query);
      
      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'lower bound (95%)', 'type' => 'number'),
        array('label' => 'upper bound (95%)', 'type' => 'number'),
        array('label' => 'mean', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['pctExcStationsLow95']);
        $temp[] = array('v' => (double) $row['pctExcStationsHigh95']);
        $temp[] = array('v' => (double) $row['pctExcStations']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

// graph of country-level pollutation forecast for given country
function query_ctry_forecast() {

    if (isset($_POST["pollutant"]) and isset($_POST["countryID"])) {
      $pollutant = $_POST["pollutant"]; 
      $countryID = $_POST["countryID"];
         
      //open connection to database
      connect_to_db(); 
    
      // perform query
      $query = "SELECT year, concentration, low95, high95, cLimit FROM airpollution.concentrationCountryForecastView WHERE pollutantID = '" . $pollutant . "' AND countryID = '" . $countryID . "'";
      $result = mysql_query($query);

      //create an array  
      $table = array();
      $table['cols'] = array(  
        array('label' => 'year', 'type' => 'string'),
        array('label' => 'limit', 'type' => 'number'),
        array('label' => 'lower bound (95%)', 'type' => 'number'),
        array('label' => 'upper bound (95%)', 'type' => 'number'),
        array('label' => 'concentration', 'type' => 'number')
      );

      $rows = array();
      while ($row = mysql_fetch_array($result)) {
        $temp = array();
        $temp[] = array('v' => (string) $row['year']); 
        $temp[] = array('v' => (double) $row['cLimit']);
        $temp[] = array('v' => (double) $row['low95']);
        $temp[] = array('v' => (double) $row['high95']);
        $temp[] = array('v' => (double) $row['concentration']);
        $rows[] = array('c' => $temp);    
      }
    
      // encode in JSON
      $table['rows'] = $rows;
      $jsonTable = json_encode($table);    
      echo $jsonTable;
    }
}

?>
