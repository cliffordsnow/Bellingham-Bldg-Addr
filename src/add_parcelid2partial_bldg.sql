--create temp table no_parcel as select * from bellingham_bldg b where parcel_code is null;
UPDATE bellingham_bldg SET parcel_code = b.gid 
FROM bellingham_parcel p join bellingham_bldg b ON ST_INTERSECTS(b.geom,p.geom) 
WHERE b.parcel_code IS NULL AND ST_AREA(ST_INTERSECTION(p.geom, b.geom)::geometry)/ST_AREA(b.geom::geometry) > .8;
