UPDATE bellingham_parcel SET no_addr = subquery.count FROM (SELECT p.gid,COUNT(*) AS count FROM bellingham_addr a, bellingham_parcel p
WHERE ST_CONTAINS(p.geom, a.geom) GROUP BY p.gid) AS subquery WHERE subquery.gid IS NOT NULL AND bellingham_parcel.gid = subquery.gid
