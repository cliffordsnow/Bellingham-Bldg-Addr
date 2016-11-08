--create temp table no_parcel as select * from bellingham_bldg b where parcel_cod is null;
UPDATE bellingham_bldg SET parcel_cod = b.gid 
FROM bellingham_parcels p join bellingham_bldg b ON ST_INTERSECTS(b.geom,p.geom) 
WHERE b.parcel_cod IS NULL AND ST_AREA(ST_INTERSECTION(p.geom, b.geom)::geometry)/ST_AREA(b.geom::geometry) > .8;
