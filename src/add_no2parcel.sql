UPDATE bellingham_parcels SET no_addr = subquery.count FROM (SELECT p.gid,COUNT(*) AS count FROM bellingham_addr a, bellingham_parcels p
WHERE ST_CONTAINS(p.geom, a.geom) GROUP BY p.gid) AS subquery WHERE subquery.gid IS NOT NULL AND bellingham_parcels.gid = subquery.gid
