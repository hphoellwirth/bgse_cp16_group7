# -------------------------------------------
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
# -------------------------------------------

/*********************/
/* Update city codes */
/*********************/
use airpollution;

DELIMITER $$

create function getCityID (name varchar(100))
  returns varchar(7)
begin
  declare cityID varchar(7);
  case name
    when 'Ankara' then set cityID = 'TR001C1';
    else               set cityID = substr(name,1,7);
  end case;
  return cityID;
end$$

create procedure updateTrCityID ()
begin
  update city
     set cityID = getCityId(cityName)
   where countryID = 'TR'; 
end$$

DELIMITER ;

call updateTrCityID();

