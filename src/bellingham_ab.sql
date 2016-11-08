﻿CREATE OR REPLACE VIEW bellingham_ba AS(
SELECT b.gid,addr_num, unit, street, zip, initcap(municipali) AS city, bldgtype, CASE WHEN num_floors = .5 THEN '.5'
                       	WHEN num_floors = 1.5 THEN '1.5'
                       	WHEN num_floors = 2.5 THEN '2.5'
                       	WHEN num_floors = 0 THEN NULL
			ELSE round(num_floors,0)::VARCHAR END AS floors, no_addr, b.geom 
FROM bellingham_addr a, bellingham_bldg b
WHERE b.gid=bldg_id AND no_addr = 1
UNION
SELECT b.gid,NULL AS addr_num, NULL as unit, ''::VARCHAR(80) AS street, ''::VARCHAR(5) AS zip, ''::VARCHAR(50) AS city,
bldgtype, CASE WHEN num_floors = .5 THEN '.5'
               	WHEN num_floors = 1.5 THEN '1.5'
               	WHEN num_floors = 2.5 THEN '2.5'
                WHEN num_floors = 0 THEN NULL
		ELSE round(num_floors,0)::VARCHAR END AS floors, no_addr, b.geom
FROM bellingham_addr a, bellingham_bldg b
WHERE st_contains(b.geom, a.geom) AND no_addr > 1 
UNION
SELECT gid, NULL AS addr_num, NULL as unit, ''::VARCHAR(80) AS street, ''::VARCHAR(5) AS zip, ''::VARCHAR(50) AS city, 
bldgtype, CASE WHEN num_floors = .5 THEN '.5'
                WHEN num_floors = 1.5 THEN '1.5'
                WHEN num_floors = 2.5 THEN '2.5'
                WHEN num_floors = 0 THEN NULL
		ELSE round(num_floors,0)::VARCHAR END AS floors, no_addr, geom
FROM bellingham_bldg WHERE no_addr IS NULL)
