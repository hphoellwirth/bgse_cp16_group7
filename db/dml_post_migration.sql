# -------------------------------------------
# BGSE Data Science 2016/17
# 14D003/14D004 Computing Project 
# Group 7
# -------------------------------------------

use airpollution;

/*******************************/
/* Add sector parent structure */
/*******************************/
update sector set parentID = '1A3' where sectorID = '1A3ai(i)';
update sector set parentID = '1A3' where sectorID = '1A3ai(ii)';
update sector set parentID = '1A3' where sectorID = '1A3aii(i)';
update sector set parentID = '1A3' where sectorID = '1A3aii(ii)';
update sector set parentID = '1A3' where sectorID = '1A3bi';
update sector set parentID = '1A3' where sectorID = '1A3bii';
update sector set parentID = '1A3' where sectorID = '1A3biii';
update sector set parentID = '1A3' where sectorID = '1A3bvi';
update sector set parentID = '1A3' where sectorID = '1A3bv';
update sector set parentID = '1A3' where sectorID = '1A3bvii';
update sector set parentID = '1A3' where sectorID = '1A3c';
update sector set parentID = '1A3' where sectorID = '1A3di(i)';
update sector set parentID = '1A3' where sectorID = '1A3di(ii)';
update sector set parentID = '1A3' where sectorID = '1A3dii';
update sector set parentID = '1A3' where sectorID = '1A3ei';
update sector set parentID = '1A3' where sectorID = '1A3eii';
update sector set parentID = '2B1' where sectorID = '2B10a';
update sector set parentID = '2B1' where sectorID = '2B10b';



/*********************/
/* Update city codes */
/*********************/
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
    when 'ADIYAMAN'   then set cityID = 'TR027C1';
    when 'AFYON'      then set cityID = 'TR028C1';
    when 'AGRI'       then set cityID = 'TR029C1';
    when 'AKSARAY'    then set cityID = 'TR030C1';
    when 'AMASYA'     then set cityID = 'TR031C1';
    when 'ARTVIN'     then set cityID = 'TR032C1';
    when 'AYDIN'      then set cityID = 'TR033C1';
    when 'BARTIN'     then set cityID = 'TR034C1';
    when 'BATMAN'     then set cityID = 'TR035C1';
    when 'BAYBURT'    then set cityID = 'TR036C1';
    when 'BILECIK'    then set cityID = 'TR037C1';
    when 'BINGOL'     then set cityID = 'TR038C1';
    when 'BITLIS'     then set cityID = 'TR039C1';
    when 'BOLU'       then set cityID = 'TR040C1';
    when 'BURDUR'     then set cityID = 'TR041C1';
    when 'CANAKKALE'  then set cityID = 'TR042C1';
    when 'CANKIRI'    then set cityID = 'TR043C1';
    when 'CORUM'      then set cityID = 'TR044C1';
    when 'DENIZLI'    then set cityID = 'TR045C1';
    when 'DUZCE'      then set cityID = 'TR046C1';
    when 'ELAZIG'     then set cityID = 'TR047C1';
    when 'ERZINCAN'   then set cityID = 'TR048C1';
    when 'ESKISEHIR'  then set cityID = 'TR049C1';
    when 'GIRESUN'    then set cityID = 'TR050C1';
    when 'GUMUSHANE'  then set cityID = 'TR051C1';
    when 'HAKKARI'    then set cityID = 'TR052C1';
    when 'IGDIR'      then set cityID = 'TR053C1';
    when 'ISPARTA'    then set cityID = 'TR054C1';
    when 'KAHRAMANMARAS' then set cityID ='TR055C1';
    when 'KARABUK'    then set cityID = 'TR056C1';
    when 'KARAMAN'    then set cityID = 'TR057C1';
    when 'KILIS'      then set cityID = 'TR058C1';
    when 'KIRIKKALE'  then set cityID = 'TR059C1';
    when 'KIRKLARELI' then set cityID = 'TR060C1';
    when 'KIRSEHIR'   then set cityID = 'TR061C1';
    when 'KUTAHYA'    then set cityID = 'TR062C1';
    when 'MARDIN'     then set cityID = 'TR063C1';
    when 'MUGLA'      then set cityID = 'TR064C1';
    when 'MUS'        then set cityID = 'TR065C1';
    when 'NIGDE'      then set cityID = 'TR066C1';
    when 'ORDU'       then set cityID = 'TR067C1';
    when 'OSMANIYE'   then set cityID = 'TR068C1';
    when 'RIZE'       then set cityID = 'TR069C1';
    when 'SINOP'      then set cityID = 'TR070C1';
    when 'SIRNAK'     then set cityID = 'TR071C1';
    when 'SIVAS'      then set cityID = 'TR072C1';
    when 'TOKAT'      then set cityID = 'TR073C1';
    when 'TUNCELI'    then set cityID = 'TR074C1';
    when 'USAK'       then set cityID = 'TR075C1';
    when 'YALOVA'     then set cityID = 'TR076C1';
    when 'YOZGAT'     then set cityID = 'TR077C1';
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

