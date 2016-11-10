# -------------------------------------------
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
# -------------------------------------------

/*******************************/
/* Add sector parent structure */
/*******************************/
update sector set parentID = '1A3' where sectorID = '1A3ai(i)';



/*********************/
/* Update city codes */
/*********************/
use airpollution;

DELIMITER $$

-- set Turkish city codes according to cityIDs from population file
-- (codes were missing in pollution file)
create function getCityID (name varchar(100))
  returns varchar(7)
begin
  declare cityID varchar(7);
  case name
    when 'Ankara'     then set cityID = 'TR001C1';
    when 'Adana'      then set cityID = 'TR002C1';
    when 'Antalya'    then set cityID = 'TR003C1';
    when 'Balikesir'  then set cityID = 'TR004C1';
    when 'Bursa'      then set cityID = 'TR005C1';
    when 'Denizli'    then set cityID = 'TR006C1';                    
    when 'Diyarbakir' then set cityID = 'TR007C1';
    when 'Edirne'     then set cityID = 'TR008C1';
    when 'Erzurum'    then set cityID = 'TR009C1';
    when 'Gaziantep'  then set cityID = 'TR010C1';
    when 'Hatay'      then set cityID = 'TR011C1';
    when 'Istanbul'   then set cityID = 'TR012C1';
    when 'Izmir'      then set cityID = 'TR013C1';                    
    when 'Kars'       then set cityID = 'TR014C1'; 
    when 'Kastamonu'  then set cityID = 'TR015C1';
    when 'Kayseri'    then set cityID = 'TR016C1';
    when 'Kocaeli'    then set cityID = 'TR017C1';
    when 'Konya'      then set cityID = 'TR018C1';
    when 'Malatya'    then set cityID = 'TR019C1';
    when 'Manisa'     then set cityID = 'TR020C1';                    
    when 'Nevsehir'   then set cityID = 'TR021C1';    
    when 'Samsun'     then set cityID = 'TR022C1';
    when 'Siirt'      then set cityID = 'TR023C1';
    when 'Trabzon'    then set cityID = 'TR024C1';
    when 'Van'        then set cityID = 'TR025C1';                    
    when 'Zonguldak'  then set cityID = 'TR026C1';             
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

-- run update of Turkish city IDs
call updateTrCityID();

