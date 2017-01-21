﻿CREATE OR REPLACE VIEW bellingham_ba AS(
SELECT b.gid,addr_num, unitid AS unit, street, 
	zip, INITCAP(municipality) AS city, b.name, yrbuilt::varchar,
	bldgtype, ROUND(num_floors::numeric,1)::VARCHAR AS floors, no_addr, b.geom 
FROM bellingham_addr a, bellingham_bldg b
WHERE b.gid=bldg_id AND no_addr = 1
UNION
SELECT b.gid,NULL AS addr_num, NULL AS unit, ''::VARCHAR(80) AS street,
	''::VARCHAR(5) AS zip, ''::VARCHAR(50) AS city, b.name, yrbuilt::varchar,
	bldgtype, ROUND(num_floors::numeric,1)::VARCHAR AS floors, no_addr, b.geom
FROM bellingham_addr a, bellingham_bldg b
WHERE ST_CONTAINS(b.geom, a.geom) AND no_addr > 1 
UNION
SELECT gid, NULL AS addr_num, NULL AS unit, ''::VARCHAR(80) AS street,
	''::VARCHAR(5) AS zip, ''::VARCHAR(50) AS city, name, yrbuilt::varchar,
	bldgtype, ROUND(num_floors::numeric,1)::VARCHAR AS floors, no_addr, geom
FROM bellingham_bldg WHERE no_addr IS NULL)
