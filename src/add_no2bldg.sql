UPDATE bellingham_bldg SET no_addr = subquery.count FROM (SELECT b.gid,COUNT(*) AS count FROM bellingham_addr a, bellingham_bldg b
WHERE ST_CONTAINS(b.geom, a.geom) GROUP BY b.gid) AS subquery WHERE subquery.gid IS NOT NULL AND bellingham_bldg.gid = subquery.gid
