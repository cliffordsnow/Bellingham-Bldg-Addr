update bellingham_addr set street = subquery.street from (select nameid, format_road(st_prefix, st_name, st_type, st_suffix) as street 
from whatcom_roads) as subquery
where bellingham_addr.st_nameid = subquery.nameid
